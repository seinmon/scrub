// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

@main
struct scrub: ParsableCommand {

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

    mutating func run() throws {
        let searchSpace = try SearchSpace(spacesFilePath: spaces)
        let cleaner = Cleaner(for: fileNameToClean, searchSpace: searchSpace)

        switch operation {
        case .uninstall:
            try cleaner.uninstall()
        case .clean:
            try cleaner.clean(force: force)
        case .list:
            try cleaner.listFiles(in: searchSpace)
        }
    }
}

enum Operation: String, Codable, CaseIterable, ExpressibleByArgument {
    case uninstall = "uninstall"
    case list = "list"
    case clean = "clean"
}
