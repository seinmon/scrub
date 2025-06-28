import Foundation

public struct ActionFactory {
    public static func create(using request: ScrubRequest) throws -> Action {
        switch request.actionType {
        case .searcher:
            return try Searcher(for: request.keyword, in: request.spacesFile, withForce: request.force)

        case .cleaner:
            return try Cleaner(for: request.keyword, in: request.spacesFile, withForce: request.force)

        case .uninstaller:
            return try Uninstaller(for: request.keyword,
                                   in: request.spacesFile,
                                   withForce: request.force)
        }
    }

    public static func create(using request: PrivilegedScrubRequest) throws -> Action {
        switch request.actionType {
        case .deletion:
            return try PrivilegedCleaner(externalAuthRef: request.externalAuthReference,
                                         targetFile: request.targetFile)
        }
    }
}

/// An interface to an action that could be performed by scrub.
public protocol Action {

    /// Performs the action.
    func perform() throws
}
