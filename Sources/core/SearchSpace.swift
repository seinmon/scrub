//
//  SearchSpace.swift
//
//
//  Created by Hossein Monjezi on 25.07.24.
//

import Foundation

/// Directories to search when scrubbing the system.
struct SearchSpace: Sequence {

    /// A representation of spaces file.
    typealias Spaces = Set<URL>

    func makeIterator() -> Spaces.Iterator {
        return spaces.makeIterator()
    }

    private let spaces: Spaces

    /// `SearchSpaces` related errors.
    enum SearchSpaceError: Error, LocalizedError {

        /// Raised when a user provided space file does not exist.
        case invalidSpacesFile

        var localizedDescription: String {
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
    init(spacesFilePath: URL? = nil) throws {
        let spacesFile = spacesFilePath == nil
        ? FileSystem.ScrubDirectory.config.url.appending(path: "search_space.plist")
        : spacesFilePath!

        do {
            self.spaces = try PropertyList.handler.read(Spaces.self, from: spacesFile)
        } catch {
            self.spaces = Set(DefaultSpace.allCases.map { return $0.url })

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

                // Just to ensure config directory exists
                _ = FileSystem(at: .config)
                try PropertyList.handler.write(spaces, to: spacesFile)
            } else {
                print("Failed to read the search space file. Using default spaces...")
            }
        }
    }
}

/// A representation of default search spaces.
fileprivate enum DefaultSpace: String, Path {

    /// Current user's Application Scripts directory.
    case applicationScripts = "Library/Application Scripts/"

    /// Current user's Application Support directory.
    case applicationSupport = "Library/Application Support/"

    /// Root Application Support directory.
    case applicationSupportRoot = "/Library/Application Support/"

    /// Current user's caches directory.
    case caches = "Library/Caches/"

    /// Root caches directory.
    case cachesRoot = "/Library/Caches/"

    /// Current user's containers directory.
    case containers = "Library/Containers"

    /// Current user's group containers directory.
    case groupContainers = "Library/Group Containers"

    /// Current user's lunch agents directory.
    case launchAgents = "Library/LaunchAgents"

    /// Root lunch agents directory.
    case launchAgentsRoot = "/Library/LaunchAgents"

    /// Root lunch deamons directory.
    case launchDaemonsRoot = "/Library/LaunchDaemons"

    var url: URL {
        return self.rawValue.first == "/"
        ? FileSystem.path(self.rawValue, relativeToCurrentUserHome: false)
        : FileSystem.path(self.rawValue, relativeToCurrentUserHome: true)
    }
}
