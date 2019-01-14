//
//  CI.swift
//  CI
//
//  Created by Tibor Bödecs on 2019. 01. 03..
//

import Foundation
import Shell
import SPM
import Git
import Env
import CI

public class SwiftCI {

    #if os(Linux)
    let fileExt = "so"
    #else
    let fileExt = "dylib"
    #endif

    var libCIPath = ".swift-ci/lib"
    let ciFileName = "CI.swift"
    let workDirName = ".ci"

    var args: [String]
    let debug: Bool
    var env: Env
    
    let projectUrl: URL
    let workUrl: URL
    let ciFileUrl: URL
    let ciLibUrl: URL

    // MARK: - init

    public init(args: [String]) {

        self.args = args
        self.debug = false
        self.projectUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        self.workUrl = self.projectUrl.appendingPathComponent(self.workDirName)//.standardized // ~
        self.ciFileUrl = self.projectUrl.appendingPathComponent(self.ciFileName)
        self.ciLibUrl = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(self.libCIPath)

        do {
            try self.workUrl.createDirectoryIfNotExists()

            self.env = try Env([
                "SWIFT_CI_PROJECT_PATH": self.projectUrl.path,
                "SWIFT_CI_WORK_PATH": self.workUrl.path,
            ])
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }

    // MARK: - run

    public func run() {

        guard let command = self.args.first else {
            fatalError("No command found!")
        }
        guard command == "run" else {
            fatalError("Invalid command!")
        }

        let workflowArgs = [
            "swiftc",
            "--driver-mode=swift",
            "-suppress-warnings",
            "-module-name SwiftCI",
            "-L \(self.ciLibUrl.path)",
            "-lCI",
            "-I \(self.ciLibUrl.path)",
            "\(self.ciFileUrl.path)",
            "-fileno 1",
        ]

        if self.debug {
            print(workflowArgs.joined(separator: " \\\n"))
        }

        do {
            let workflowCommand = workflowArgs.joined(separator: " ")
            let jsonString = try Shell().run(workflowCommand)
            let decoder = JSONDecoder()
            guard let jsonData = jsonString.data(using: .utf8) else {
                fatalError("Invalid data.")
            }
            let project = try decoder.decode(Project.self, from: jsonData)
            guard var workflow = project.workflows.first else {
                fatalError("No available workflows.")
            }
            if self.args.count > 1 {
                let name = self.args[1]
                if let wf = project.workflows.filter({ $0.name == name }).first {
                    workflow = wf
                }
            }

            let logo = """
                   ____       _ _____  _________
                  / __/    __(_) _/ /_/ ___/  _/
                 _\\ \\| |/|/ / / _/ __/ /___/ /
                /___/|__,__/_/_/ \\__/\\___/___/

                """

            print(logo)
            print("🤖 Workflow: \(workflow.name)")
            
            try workflow.tasks.forEach { task in

                var args: [String: String] = [:]
                task.inputs.forEach { key, value in
                    args[key] = value
                }
                let params = args.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
                let taskDir = task.name + "@" + task.version
                let taskUrl = self.workUrl.appendingPathComponent("tasks")
                                          .appendingPathComponent(taskDir)

                let taskBinary = taskUrl.appendingPathComponent(task.name)
 
                let runCommand = "\(taskBinary.path) \(params)"
                
                let isBinaryAvailable = FileManager.default.fileExists(atPath: taskBinary.path)
                let binaryStatusIcon = isBinaryAvailable ? "🤘🏼" : "🔨"

                print("\n🎯 \(task.name) task (version: \(task.version), \(binaryStatusIcon))")

                if isBinaryAvailable {
                    self.run(command: runCommand)
                    return
                }
                
                guard let url = URL(string: task.url) else {
                    fatalError("Invalid url!")
                }

                let taskCheckoutDir = self.workUrl.appendingPathComponent("checkouts")
                                                  .appendingPathComponent(taskDir)
                
                let taskSourceDir = taskCheckoutDir.appendingPathComponent(task.name)

                do {
                    let git = Git(path: taskCheckoutDir.path)
                    git.verbose = self.debug
                    try git.run(.clone(url: url.absoluteString))
                    git.path = taskSourceDir.path
                    try git.run(.cmd(.checkout), args: ["tags/\(task.version)"])
                }
                catch let error as ShellError {
                    // only catch git errors for now (if something goes wrong at this point that's bad for you...)
                    if self.debug {
                        print(error.localizedDescription)
                    }
                }
                
                let spm = SPM(path: taskSourceDir.path)
                try spm.run(.build, flags: [.config(.release)])
                let binaryPath = try spm.run(.build, flags: [.config(.release), .showBinaryPath])
                let binaryUrl = URL(fileURLWithPath: binaryPath).appendingPathComponent(task.name)
                
                try taskUrl.createDirectoryIfNotExists()
                try FileManager.default.copyItem(at: binaryUrl, to: taskBinary)
                try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: taskBinary.path)
                
                self.run(command: runCommand)
            }

            print("\n🤖 Workflow completed.\n")

            try? self.env.destroy()
        }
        catch {
            print(error.localizedDescription)
        }
    }

    func run(command: String) {
        do {
            let out = try Shell().run(command)
            print(out)
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
