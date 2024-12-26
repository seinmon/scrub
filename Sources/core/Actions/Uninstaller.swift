//
//  Uninstaller.swift
//  
//
//  Created by Hossein Monjezi on 11.08.24.
//

import Foundation

/// Uninstall an Application and cleanup afterwards.
final public class Uninstaller: DestructiveAction {

    /// `Uninstaller` related errors.
    enum UninstallerError: Error, LocalizedError {

        /// Raised when the target application is not found.
        case bundleIdError(String)

        var localizedDescription: String {
            switch self {
            case .bundleIdError(let message):
                return "Failed to get bundle id: " + message
            }
        }
    }

    override public func perform() throws {
        var installedLocations = Set<URL>()

        for applicationDir in FileSystem.Directory.applications {
            let locations = try FileSystem.shared.locate(Regex(targetFile), in: applicationDir)
            installedLocations = installedLocations.union(locations)
        }

        if installedLocations.isEmpty {
            print("Application not found!")
        }

        for application in installedLocations {
            try delete(application, force: false)
        }
    }
}
