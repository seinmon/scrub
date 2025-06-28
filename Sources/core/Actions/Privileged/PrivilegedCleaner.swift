import Foundation

/// A privileged action that deletes target files from the file system.
class PrivilegedCleaner: PrivilegedAction {
    override public func perform() throws {
        try authService.validate()
        try FileSystem.shared.delete(file)
    }
}
