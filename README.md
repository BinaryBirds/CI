# Swift CI

Swift + Continuous Integration service = ❤️ 



⚠️ Please note that this is just a proof of concept!



## Installation

```shell
git clone https://github.com/BinaryBirds/CI.git
cd CI
make install #or swift run install
```

No brew or mint support? Not yet. Be patient. 😉 

## Usage

Just create a `CI.swift` file to define your workflows like this.

```swift
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

```

Task should be valid Swift package repositories with executable targets (task name = executable target). Input parameters will be available through the `CommandLine.arguments` variable, but you can also pass around environment variables as well. See `OutputGenerator` task for more example. Local & remote repositories are both supported. 

Run workflow:  `swift ci run` runs the first one in the workflows array or you cna use `swift ci run workflow-name` to run a specific one (eg. `swift ci run linux`).



## License

[WTFPL](LICENSE) - Do what the fuck you want to.
