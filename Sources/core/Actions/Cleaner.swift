import Foundation

/// Deletes files and directories.
final public class Cleaner: DestructiveAction {
    override public func perform() throws {
        let locations = try locate(searchQuery: getQuery(using: targetFile))

        if locations.isEmpty {
            print("Nothing to clean!")
        }

        try delete(locations, force: force)
    }
}
