import Foundation

/// Action factory, as suggested by its name, creates a concrete action based on a request.
public struct ActionFactory {

    /// Creates a non-privileged action.
    ///
    /// - Parameters:
    ///    - request: A request describing the desired action.
    public static func create(using request: ScrubRequest) throws -> Action {
        switch request.actionType {
        case .searcher:
            return try Searcher(for: request.keyword,
                                in: request.spacesFile,
                                withForce: request.force)

        case .cleaner:
            return try Cleaner(for: request.keyword,
                               in: request.spacesFile,
                               withForce: request.force)

        case .uninstaller:
            return try Uninstaller(for: request.keyword,
                                   in: request.spacesFile,
                                   withForce: request.force)
        }
    }

    /// Creates a privileged action.
    ///
    /// - Parameters:
    ///    - request: A request describing the desired action.
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
