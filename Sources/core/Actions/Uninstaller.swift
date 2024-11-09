//
//  Uninstaller.swift
//  
//
//  Created by Hossein Monjezi on 11.08.24.
//

import Foundation

final public class Uninstaller: DestructiveAction {

    enum UninstallerError: Error, LocalizedError {
        case bundleIdError(String)

        var localizedDescription: String {
            switch self {
            case .bundleIdError(let message):
                return "Failed to get bundle id: " + message
            }
        }
    }

    override public func perform() throws {
        let fs = FileSystem()
        var installedLocations = Set<URL>()

        for applicationDir in FileSystem.Directory.applications {
            let locations = try fs.locate(Regex(targetFile), in: applicationDir)
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
