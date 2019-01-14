//
//  Task.swift
//  CI
//
//  Created by Tibor Bödecs on 2019. 01. 03..
//

public struct Task: Codable {

    public var name: String
    public var url: String
    public var version: String
    public var inputs: [String: String]

    public init(name: String, url: String, version: String, inputs: [String: String]) {
        self.name = name
        self.url = url
        self.version = version
        self.inputs = inputs
    }
}
