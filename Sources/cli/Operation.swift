import Foundation
import ScrubCore
import ArgumentParser

/// Supported operations by Scrub command-line tool.
enum Operation: String, Codable, CaseIterable, ExpressibleByArgument {
    case uninstall = "uninstall"
    case list = "list"
    case clean = "clean"

    /// Returns the action type for each operation.
    var actionType: ActionType {
        switch self {
        case .uninstall:
            return .uninstaller

        case .list:
            return .searcher

        case .clean:
            return .cleaner

        }
    }
}
