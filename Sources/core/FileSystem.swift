//
//  FileSystem.swift
//
//
//  Created by Hossein Monjezi on 24.07.24.
//

import Foundation

/// File system handler.
struct FileSystem {
    private let baseDirectory: URL

    /// Home directory of the current user.
    static var homeDirectoryForCurrentUser: URL {
        return FileManager.default.homeDirectoryForCurrentUser
    }

    static var applicationDirectories: [URL] {
        return FileManager.default.urls(for: .applicationDirectory, in: .allDomainsMask)
    }

    /// A representation of repositories owned by scrub.
    enum ScrubDirectory: String, Path {

        /// Config directory.
        case config = ".scrub"

        var url: URL {
            FileSystem.path(self.rawValue, relativeToCurrentUserHome: true)
        }
    }

    private var fileManager: FileManager {
        FileManager.default
    }

    /// Create a file system handle at home directory of the current user.
    init() {
        self.baseDirectory = FileSystem.homeDirectoryForCurrentUser
    }

    /// Create a file system handle at a scrub directory.
    ///
    /// - Parameters:
    ///   - baseDirectory: A scrub directory to use as the working directory.
    init?(at baseDirectory: FileSystem.ScrubDirectory) {
        self.baseDirectory = baseDirectory.url

        var baseDirExists: ObjCBool = false
        fileManager.fileExists(atPath: baseDirectory.url.path(), isDirectory: &baseDirExists)

        if !baseDirExists.boolValue {
            do {
                try createDirectory(at: baseDirectory.url, withIntermediateDirectories: true)
            } catch {
                return nil
            }
        }
    }

    /// Create a file system handle at a directory.
    ///
    /// - Parameters:
    ///   - baseDirectory: A `URL` to use as the working directory.
    init?(at baseDirectory: URL) {
        guard (try? baseDirectory.isDirectory) ?? false else {
            return nil
        }

        self.baseDirectory = baseDirectory
    }

    /// Locate files and subdirectories within working directory using a query.
    ///
    /// - Parameters:
    ///   - query: A regular expression to use identify files and subdirectories. If this query is not given, everything in the working
    ///             directory is returned.
    ///
    /// - Returns: An optional set of `URL`s within the working directory.
    func locate(_ query: Regex<Substring>, in workingDirectory: URL? = nil) throws -> Set<URL> {
        var findings = Set<URL>()

        var resolvedDirectory: URL! = nil

        // XXX - resolvedDirectory is force unwrapped. Be careful when changing!
        if let workingDirectory = workingDirectory {
            resolvedDirectory = workingDirectory.resolvingSymlinksInPath()
        } else {
            resolvedDirectory = baseDirectory.resolvingSymlinksInPath()
        }

        if let enumerator = fileManager.enumerator(at: resolvedDirectory,
                                                   includingPropertiesForKeys: nil,
                                                   options: .skipsSubdirectoryDescendants) {
            while let element = enumerator.nextObject() as? URL {
                if element.lastPathComponent.contains(query) {
                    findings.insert(element)
                }
            }
        }

        return findings
    }

    /// Creates a directory within the current working directory.
    ///
    /// This method is simply a wrapper around `FileManager`'s function:
    /// ```
    ///func createDirectory(
    ///    at url: URL,
    ///    withIntermediateDirectories createIntermediates: Bool,
    ///    attributes: [FileAttributeKey : Any]? = nil
    ///) throws
    ///```
    /// Therefore, it is best to refer to the original documentations.
    ///
    /// - Parameters:
    ///   - url: A file `URL` to the directory to create.
    ///   - createIntermediates: If set, it will create all non-existent directories in the `url`.
    ///   - attributes: Attributes to apply when creating the directory.
    func createDirectory(at url: URL,
                         withIntermediateDirectories createIntermediates: Bool,
                         attributes: [FileAttributeKey : Any]? = nil) throws {
        try fileManager.createDirectory(at: url,
                                        withIntermediateDirectories: createIntermediates,
                                        attributes: attributes)
    }

    func delete(_ url: URL) throws {
        try fileManager.removeItem(at: url)
    }

    /// Generate a `URL` using a path `String`.
    ///
    /// - Parameters:
    ///   - path: Path to the target file or directory.
    ///   - fromHome: If set, the generated path is relative to home directory of the current user.
    ///
    /// - Returns: A `URL` to the target location.
    static func path(_ path: String, relativeToCurrentUserHome fromHome: Bool) -> URL {
        return fromHome
        ? FileSystem.homeDirectoryForCurrentUser.appending(path: path)
        : URL(filePath: path)
    }
}
