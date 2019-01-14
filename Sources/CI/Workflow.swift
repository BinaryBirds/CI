//
//  Workflow.swift
//  CI
//
//  Created by Tibor Bödecs on 2019. 01. 03..
//

public struct Workflow: Codable {

    public var name: String
    public var tasks: [Task]

    public init(name: String, tasks: [Task]) {
        self.name = name
        self.tasks = tasks
    }
}
