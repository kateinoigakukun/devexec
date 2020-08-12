import Foundation

@dynamicMemberLookup
struct PathMode {
    struct Content: Codable {
        var path: String
    }
    
    var name: String
    var content: Content
    
    subscript<T>(dynamicMember keyPath: KeyPath<Content, T>) -> T {
        content[keyPath: keyPath]
    }
}

struct MessageError: LocalizedError {
    let message: String
    var errorDescription: String? {
        return message
    }
    init(_ message: String) {
        self.message = message
    }
}

class PathModeRegistry {
    let registryDirectory: URL
    init(registryDirectory: URL) {
        self.registryDirectory = registryDirectory
    }
    lazy var modesDirectory: URL = {
        let url = registryDirectory.appendingPathComponent("modes")

        let isExists = FileManager.default.fileExists(atPath: url.path, isDirectory: nil)
        if !isExists {
            try! FileManager.default.createDirectory(
                atPath: url.path,
                withIntermediateDirectories: true,
                attributes: [:]
            )
        }
        return url
    }()

    func getByName(_ name: String) throws -> PathMode {
        let url = modesDirectory.appendingPathComponent(name)
        let isExists = FileManager.default.fileExists(atPath: url.path, isDirectory: nil)
        guard isExists else {
            throw MessageError("Mode \(name) doesn't exist")
        }
        let data = try Data(contentsOf: url)
        let content = try JSONDecoder().decode(PathMode.Content.self, from: data)
        return PathMode(name: name, content: content)
    }
    
    func register(_ mode: PathMode) throws {
        let url = modesDirectory.appendingPathComponent(mode.name)
        let isExists = FileManager.default.fileExists(atPath: url.path, isDirectory: nil)
        guard !isExists else {
            throw MessageError("Mode \(mode.name) already exist")
        }
        let data = try JSONEncoder().encode(mode.content)
        try data.write(to: url)
    }
    
    func unregister(_ name: String) throws {
        let url = modesDirectory.appendingPathComponent(name)
        let isExists = FileManager.default.fileExists(atPath: url.path, isDirectory: nil)
        guard isExists else {
            throw MessageError("Mode \(name) doesn't exist")
        }
        try FileManager.default.removeItem(at: url)
    }
    
    func allModeNames() throws -> [String] {
        let contents = try FileManager.default.contentsOfDirectory(at: modesDirectory, includingPropertiesForKeys: nil)
        return contents.map { $0.lastPathComponent }
    }
}

func usage() {
    let content = """
USAGE:
   devexec command [arguments...]

COMMANDS:
   add          Add new path mode
   delete       Add new path mode
   list         List path mode
   [path mode]  Execute command in the path mode
"""
    fputs(content, stderr)
}

let registryDirectory = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".config")
    .appendingPathComponent("devexec")

let registry = PathModeRegistry(
    registryDirectory: registryDirectory
)


func exec(command: [String], in mode: PathMode) throws {
    let process = Process()
    process.environment = ProcessInfo.processInfo.environment
    let oldPath = process.environment!["PATH"]!
    let newPath = "\(mode.path):\(oldPath)"
    process.environment!["PATH"] = newPath
    process.launchPath = "/usr/bin/env"
    process.arguments = command
    process.launch()
    process.waitUntilExit()
}

func validateArgument(_ minArguments: Int) {
    guard CommandLine.arguments.count >= minArguments else {
        usage()
        exit(1)
    }
}

func main() throws {
    let arguments = CommandLine.arguments
    validateArgument(2)
    let command = arguments[1]
    switch command {
    case "add":
        validateArgument(3)
        let name = arguments[2]
        let path = arguments[3]
        let mode = PathMode(name: name, content: .init(path: path))
        try registry.register(mode)
    case "delete":
        let name = arguments[2]
        try registry.unregister(name)
    case "list":
        let output = try registry.allModeNames().joined(separator: "\n")
        print(output)
    default:
        validateArgument(3)
        let maybeName = command
        let mode = try registry.getByName(maybeName)
        try exec(command: Array(arguments[2...]), in: mode)
    }
}

do {
    try main()
} catch let error as MessageError {
    fputs(error.message + "\n", stderr)
    usage()
    exit(1)
}
