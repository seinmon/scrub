//
//  FileSystem.swift
//
//
//  Created by Hossein Monjezi on 24.07.24.
//

import Foundation

/// File system handler.
struct FileSystem {
    struct Directory {
        static var homeDirectoryForCurrentUser: URL {
            FileManager.default.homeDirectoryForCurrentUser
        }

        static var applicationSupport: [URL] {
            FileManager.default.urls(for: .applicationSupportDirectory, in: .allDomainsMask)
        }

        static var applications: [URL] {
            FileManager.default.urls(for: .applicationDirectory, in: .allDomainsMask)
        }
    }

    struct File {
        static var config: URL {
            let applicationSupportDir = FileManager.default.urls(for: .applicationSupportDirectory,
                                                                 in: .systemDomainMask)
            guard applicationSupportDir.count == 1 else {
                return URL(filePath: "/Library/Application Support/scrub/spaces.plist")
            }

            return applicationSupportDir[0].appending(path: "scrub/spaces.plist")
        }
    }

    private var fileManager: FileManager {
        FileManager.default
    }

    /// Create a file system handle.
    public init() {
        // Makes internal available.
    }

    /// Locate files and subdirectories within working directory using a query.
    ///
    /// - Parameters:
    ///   - query: A regular expression to use identify files and subdirectories. If this query is not given, everything in the working
    ///             directory is returned.
    ///
    /// - Returns: An optional set of `URL`s within the working directory.
    func locate(_ query: Regex<Substring>, in workingDirectory: URL) throws -> Set<URL> {
        var findings = Set<URL>()
        let resolvedDirectory = workingDirectory.resolvingSymlinksInPath()

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

}
