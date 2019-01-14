//
//  main.swift
//  CI
//
//  Created by Tibor Bödecs on 2019. 01. 14..
//

import Foundation
import SPM
import Utility

#if os(Linux)
let fileExt = "so"
#else
let fileExt = "dylib"
#endif

var libPath = ".swift-ci/lib"
var binPath = "/usr/local/bin"
let executableName = "swift-ci"
let files = ["CI.swiftdoc", "CI.swiftmodule", "libCI.\(fileExt)"]
let homeDir = URL(fileURLWithPath: NSHomeDirectory())

let spm = SPM(path: ".")
try spm.run(.build, flags: [.config(.release)])
let buildPath = try spm.run(.build, flags: [.config(.release), .showBinaryPath])
let buildUrl = URL(fileURLWithPath: buildPath)
let libDestUrl = homeDir.appendingPathComponent(libPath)

if !FileManager.default.fileExists(atPath: libDestUrl.path) {
    try FileManager.default.createDirectory(atPath: libDestUrl.path,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
}

try files.forEach { name in
    let sourceFileUrl = buildUrl.appendingPathComponent(name)
    let destFileUrl = libDestUrl.appendingPathComponent(name)

    if FileManager.default.fileExists(atPath: destFileUrl.path) {
        try FileManager.default.removeItem(at: destFileUrl)
    }
    try FileManager.default.copyItem(at: sourceFileUrl, to: destFileUrl)
}

let binSourceFileUrl = buildUrl.appendingPathComponent(executableName)
let binDestFileUrl = URL(fileURLWithPath: binPath).appendingPathComponent(executableName)

print(binDestFileUrl)

if FileManager.default.fileExists(atPath: binDestFileUrl.path) {
    try FileManager.default.removeItem(at: binDestFileUrl)
}
try FileManager.default.copyItem(at: binSourceFileUrl, to: binDestFileUrl)
try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: binDestFileUrl.path)
