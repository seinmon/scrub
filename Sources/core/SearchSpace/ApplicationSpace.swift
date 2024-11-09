//
//  ApplicationSpace.swift
//  
//
//  Created by Hossein Monjezi on 17.08.24.
//

import Foundation

/// A representation of default application related search spaces.
enum ApplicationSpace: String, CaseIterable {

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
        ? generatePath(self.rawValue, relativeToCurrentUserHome: false)
        : generatePath(self.rawValue, relativeToCurrentUserHome: true)
    }

    /// Generate a `URL` using a path `String`.
    ///
    /// - Parameters:
    ///   - path: Path to the target file or directory.
    ///   - fromHome: If set, the generated path is relative to home directory of the current user.
    ///
    /// - Returns: A `URL` to the target location.
    private func generatePath(_ path: String, relativeToCurrentUserHome fromHome: Bool) -> URL {
        return fromHome
        ? FileSystem.Directory.homeDirectoryForCurrentUser.appending(path: path)
        : URL(filePath: path)
    }
}
