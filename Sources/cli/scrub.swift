import ArgumentParser
import Foundation
import ScrubCore

@main
struct Scrub: ParsableCommand {

    static let configuration = CommandConfiguration(
        version: "0.1.0"
    )

    @Argument(help: "Operation to perform.")
    var operation: Operation

    @Argument(help: "Name or part of the target files to clean.")
    var fileNameToClean: String

    @Option(name: [.short, .long],
            help: "A spaces file to use when searching for files to delete.",
            transform: {(arg) in URL(filePath: arg, directoryHint: .notDirectory)})
    var spaces: URL? = nil

    @Flag(name: [.short, .long], help: "If set, files are deleted without user confirmation.")
    var force: Bool = false

    private var searchSpace: SearchSpace {
        get throws {
            try SearchSpace(spacesFilePath: spaces)
        }
    }

    mutating func run() throws {
        let operation = try getAction(for: operation)
        try operation.perform()
    }

    private func getAction(for operation: Operation) throws -> Action {
        switch operation {
        case .uninstall:
            return try Uninstaller(for: fileNameToClean, in: searchSpace, withForce: force)

        case .clean:
            return try Cleaner(for: fileNameToClean, in: searchSpace, withForce: force)

        case .list:
            return try Searcher(for: fileNameToClean, in: searchSpace, withForce: force)
        }
    }
}
