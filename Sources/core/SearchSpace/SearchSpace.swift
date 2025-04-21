import Foundation

/// Directories to search when scrubbing the system.
public struct SearchSpace: Sequence {

    public func makeIterator() -> Spaces.Iterator {
        return spaces.makeIterator()
    }

    private let spaces: Spaces

    /// `SearchSpaces` related errors.
    enum SearchSpaceError: Error, LocalizedError {

        /// Raised when a user provided space file does not exist.
        case invalidSpacesFile

        var errorDescription: String? {
            switch self {
            case .invalidSpacesFile:
                return "Invalid search space file."
            }
        }
    }

    /// Initialize a search space using a spaces file.
    ///
    /// - Parameters:
    ///   - spacesFilePath: A `URL` to a `plist` containing search spaces. If this argument is not given, default spaces file
    ///     is used instead.
    ///
    /// If `spacesFilePath` is not provided, default search spaces are used during the initialization. If the default spaces cannot be
    /// located in the file system, it will be created as well. On the contrary, if this argument if specified, it must be a valid file on the
    /// file system.
    ///
    /// - throws:`SearchSpaceError.invalidSpacesFile` when a user provided spaces file is invalid.
    public init(spacesFilePath: URL? = nil) throws {
        let spacesFile = spacesFilePath == nil ? FileSystem.File.config : spacesFilePath!

        do {
            self.spaces = try Spaces.read(from: spacesFile)
        } catch {
            self.spaces = Spaces(data: Set(ApplicationSpace.allCases.map { return $0.url }))

            if let error = error as? CocoaError, error.code == .fileReadNoSuchFile {
                // If user provides an invalid spaces file, throw an error and exit, otherwise
                // create the default spaces file.
                guard spacesFilePath == nil else {
                    throw SearchSpaceError.invalidSpacesFile
                }

                print("""
                    Search space file does not exist. \
                    Creating default search space at \(spacesFile.path()).
                    You can modify this file to add to, or remove a directory from the search space.
                    """)

                try spaces.write(to: spacesFile)
            } else {
                print("""
                    Failed to read the search space file with error \(error.localizedDescription). \
                    Using default spaces...
                    """)
            }
        }
    }
}
