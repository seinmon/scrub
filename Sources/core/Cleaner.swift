//
//  Cleaner.swift
//  scrub
//
//  Created by Hossein Monjezi on 14.07.24.
//

import Foundation

/// Performs cleaning related tasks.
struct Cleaner {
    private let searchSpace: SearchSpace
    private let targetFile: String

    enum CleanerError: Error, LocalizedError {
        case bundleIdError(String)
        case inputError

        var localizedDescription: String {
            switch self {
            case .bundleIdError(let message):
                return "Failed to get bundle id: " + message
            case .inputError:
                return "Invalid input from user."
            }
        }
    }

    init(for targetFile: String, searchSpace: SearchSpace) {
        self.searchSpace = searchSpace
        self.targetFile = targetFile
    }

    func uninstall() throws {
        let targetBundleId = try findBundleId(of: targetFile + ".app")
        let fs = FileSystem()
        var installedLocations = Set<URL>()

        for applicationDir in FileSystem.applicationDirectories {
            let locations = try fs.locate(Regex(targetFile), in: applicationDir)
            installedLocations = installedLocations.union(locations)
        }

        if installedLocations.isEmpty {
            print("Application not found!")
        }

        for application in installedLocations {
            try delete(application, force: false)
        }

        try clean(getQuery(for: targetBundleId), force: false)
    }

    func clean(force: Bool) throws {
        try clean(getQuery(for: targetFile), force: force)
    }

    private func clean(_ query: Regex<Substring>, force: Bool) throws {
        let belongings = try findFiles(with: query, in: searchSpace)

        if belongings.isEmpty {
            print("Nothing to clean!")
        }

        for file in belongings {
            try delete(file, force: force)
        }
    }

    func listFiles(in searchSpace: SearchSpace) throws {
        let findings = try findFiles(with: getQuery(for: targetFile), in: searchSpace)

        if findings.isEmpty {
            print("No files found!")
        }

        for file in findings {
            print(file.path())
        }
    }

    private func getQuery(for target: String) throws -> Regex<Substring> {
        return try Regex("[A-Za-z0-9_.]*\(target)[A-Za-z0-9_.]*")
    }

    private func findFiles(with query: Regex<Substring>,
                           in searchSpace: SearchSpace) throws -> Set<URL> {
        var belongings = Set<URL>()

        for space in searchSpace {
            if let findings = try FileSystem(at: space)?.locate(query) {
                belongings = belongings.union(findings)
            }
        }

        return belongings
    }

    private func findBundleId(of application: String) throws -> String {
        let getBundleIdCommand = "id of app \"" + application + "\""
        var error: NSDictionary? = nil

        guard let osascript = NSAppleScript(source: getBundleIdCommand) else {
            throw CleanerError.bundleIdError("Failed to instantiate an Apple Script object.")
        }

        let output = osascript.executeAndReturnError(&error)

        if let error = error {
            if let errorMessage = error["NSAppleScriptErrorMessage"] as? String {
                throw CleanerError.bundleIdError(errorMessage)
            } else if let briefMessage = error["NSAppleScriptErrorMessage"] as? String {
                throw CleanerError.bundleIdError(briefMessage)
            } else {
                throw CleanerError.bundleIdError("Apple Script failed with unknown error.")
            }
        }

        guard let bundleId = output.stringValue else {
            throw CleanerError.bundleIdError("Apple Script has an invalid output.")
        }

        return bundleId
    }

    private func delete(_ file: URL, force: Bool) throws {
        if !force {
            while true {
                print("Delete \(file.path())? (Y/n)")

                if let response = readLine()?.first {
                    if response.lowercased() == "y" {
                        break
                    } else if response.lowercased() == "n" {
                        print("Skipping \(file.path())")
                        return
                    } else {
                        print("Unrecognized input.")
                    }
                }
            }
        }

        try FileSystem().delete(file)
    }
}
