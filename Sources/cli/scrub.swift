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

    @Argument(help: "Name or part of the target file name to clean.")
    var fileNameToClean: String

    @Option(name: [.short, .long],
            help: "A spaces file to use when searching for files to delete.",
            transform: {(arg) in URL(filePath: arg, directoryHint: .notDirectory)})
    var spaces: URL? = nil

    @Flag(name: [.short, .long], help: "If set, files are deleted without user confirmation.")
    var force: Bool = false

    mutating func run() throws {
        let request = ScrubRequest(actionType: operation.actionType,
                               targetFile: fileNameToClean,
                               force: force,
                               spacesFile: spaces)
        try ActionFactory.create(using: request)
            .perform()
    }
}
