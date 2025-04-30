import Foundation

/// An interface to an action that could be performed by scrub.
public protocol Action {

    /// Performs the action.
    func perform() throws
}

/// Abstract non-destructive action.
public class BasicAction: Action {

    /// Target of the action.
    let targetFile: String

    /// Search space where the action should be performed.
    let searchSpace: SearchSpace

    /// If set to `True`, the action will be performed without asking for the user's confirmation.
    let force: Bool

    public init(for targetFile: String, in spacesFile: URL?, withForce force: Bool) throws {
        self.searchSpace = try SearchSpace(spacesFilePath: spacesFile)
        self.targetFile = targetFile
        self.force = force
    }

    public func perform() throws {
        fatalError("Cannot perform an abstract action.")
    }

    /// Returns a regular expression that matches the target with all kinds of prefixes and postfixes.
    ///
    /// - Parameters:
    ///    - target: The target file name to use when generating the query.
    ///
    /// - Returns: A regular expression that matches the target with all kinds of prefixes and postfixes.
    ///
    /// - Throws: Propagates exception when creating the query.
    func getQuery(using target: String) throws -> Regex<Substring> {
        return try Regex("[A-Za-z0-9_.]*\(target)[A-Za-z0-9_.]*")
    }

    /// Locates files based on a search query.
    ///
    /// - Parameters:
    ///    - searchQuery: A regular expression to use when searching for files in the search space.
    ///
    /// - Returns: A set of `URL`s that matched the `searchQuery`.
    func locate(searchQuery: Regex<Substring>) -> Set<URL> {
        var locations = Set<URL>()

        for space in searchSpace {
            locations = locations.union(FileSystem.shared.locate(searchQuery, in: space))
        }

        return locations
    }
}

/// An action that can delete files and directories.
public class DestructiveAction: BasicAction {

    /// The required right for performing a privileged destructive action.
    class var authRequestRight: AuthorizationRequestRight {
        fatalError("Cannot get authorization right from an abstract destructive action.")
    }

    /// Delete a file or directory.
    ///
    /// - Parameters:
    ///    - file: `URL` to delete.
    ///    - force: If set, will not ask for user's confirmation before deleting the target file.
    func delete(_ files: Set<URL>, force: Bool) throws {
        filesLoop: for file in files {
            if !force {
                responseLoop: while true {
                    print("Delete \(file.pathWithoutPercentEncoding)? (Y/n)")

                    if let response = readLine()?.first?.lowercased() {
                        switch response {
                        case "n":
                            print("Skipping \(file.pathWithoutPercentEncoding)")
                            continue filesLoop

                        case "y":
                            break responseLoop

                        default:
                            print("Unrecognized input.")
                        }
                    }
                }
            }

            try delete(file)
        }
    }

    private func delete(_ file: URL) throws {
        try file.isOwnedByRoot ? try privilegedDelete(file) : try unprivilegedDelete(file)
    }

    private func privilegedDelete(_ file: URL) throws {
        var authService = try AuthorizationService(for: Self.authRequestRight)
        var externalAuthForm = try authService.authorizeForPrivilegedServices()
        // TODO: Call `scrub-service`
    }

    private func unprivilegedDelete(_ file: URL) throws {
        try FileSystem.shared.delete(file)
    }
}
