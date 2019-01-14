//
//  URL.swift
//  CI
//
//  Created by Tibor Bödecs on 2019. 01. 03..
//

import Foundation

extension URL {
    
    var subDirectories: [URL] {
        guard isDirectory else {
            return []
        }
        let contents = try? FileManager.default.contentsOfDirectory(at: self,
                                                                    includingPropertiesForKeys: nil,
                                                                    options: [.skipsHiddenFiles])
        return contents?.filter{ $0.isDirectory } ?? []
    }

    var isDirectory: Bool {
        var isDir = ObjCBool(false)
        if FileManager.default.fileExists(atPath: self.path, isDirectory: &isDir) {
            return isDir.boolValue
        }
        return false
    }

    func createDirectoryIfNotExists() throws {
        guard !self.isDirectory else {
            return
        }
        try FileManager.default.createDirectory(atPath: self.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
    }
}
