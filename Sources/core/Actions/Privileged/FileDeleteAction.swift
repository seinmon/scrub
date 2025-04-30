import Foundation

/// A privileged action that deletes target files from the file system.
public class FileDeleteAction: PrivilegedAction {
    public override func perform() throws {
        try authService.validate()

        for file in files {
            try FileSystem.shared.delete(file)
        }
    }
}
