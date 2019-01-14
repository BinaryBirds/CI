import CI

let buildWorkflow = Workflow(
    name: "default",
    tasks: [
        Task(name: "HelloWorld",
             url: "git@github.com:BinaryBirds/HelloWorld.git",
             version: "1.0.0",
             inputs: [:]),

        Task(name: "OutputGenerator",
             url: "~/ci/Tasks/OutputGenerator",
             version: "1.0.0",
             inputs: [:]),

        Task(name: "SampleTask",
             url: "git@github.com:BinaryBirds/SampleTask.git",
             version: "1.0.1",
             inputs: ["task-input-parameter": "Hello SampleTask!"]),
    ])

let testWorkflow = Workflow(
    name: "linux",
    tasks: [
        Task(name: "SampleTask",
             url: "https://github.com/BinaryBirds/SampleTask.git",
             version: "1.0.0",
             inputs: ["task-input-parameter": "Hello SampleTask!"]),
        ])

let project = Project(name: "Example",
                      url: "git@github.com:BinaryBirds/Example.git",
                      workflows: [buildWorkflow, testWorkflow])
