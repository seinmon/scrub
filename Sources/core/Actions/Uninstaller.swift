import Foundation

/// Uninstall an Application and cleanup afterwards.
final public class Uninstaller: DestructiveAction {
    override public func perform() throws {
        var installedLocations = Set<URL>()

        for applicationDir in FileSystem.Directory.applications {
            let locations = try FileSystem.shared.locate(Regex(targetFile), in: applicationDir)
            installedLocations = installedLocations.union(locations)
        }

        if installedLocations.isEmpty {
            print("Application not found!")
        }

        try delete(installedLocations, force: false)
    }
}
