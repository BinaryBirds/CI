//
//  Project.swift
//  CI
//
//  Created by Tibor Bödecs on 2019. 01. 03..
//

import Foundation

public struct Project: Codable {

    public var name: String
    public var url: String

    public var workflows: [Workflow]

    public init(name: String, url: String, workflows: [Workflow]) {
        self.name = name
        self.url = url
        self.workflows = workflows
        
        _registerExitHandler(for: self)
    }
}

// MARK: - Writes the encoded Workflow object to a file by using a file descriptor number (-fileno) on exit
// See: https://github.com/apple/swift-package-manager

private var outputInfo: (project: Project, fileDescriptorNumber: Int32)?

private func _registerExitHandler(for project: Project) {
    guard CommandLine.argc > 0,
        let fileDescriptorNumberIndex = CommandLine.arguments.index(of: "-fileno"),
        let fileDescriptorNumber = Int32(CommandLine.arguments[fileDescriptorNumberIndex + 1])
    else {
        return
    }
    _writeOutputAtExit(project, to: fileDescriptorNumber)
}

private func _writeOutputAtExit(_ project: Project, to fileDescriptorNumber: Int32) {
    
    func writeOutputToFile() {
        let encoder = JSONEncoder()
        
        guard
            let info = outputInfo,
            let jsonData = try? encoder.encode(info.project),
            let jsonString = String(data: jsonData, encoding: .utf8),
            let fileDescriptor = fdopen(info.fileDescriptorNumber, "w")
        else {
            return
        }
        
        fputs(jsonString, fileDescriptor)
        fclose(fileDescriptor)
    }
    outputInfo = (project, fileDescriptorNumber)
    atexit(writeOutputToFile)
}
