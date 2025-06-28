import Foundation

/// A representation of possible privileged actions.
///
/// Currently, `scrub` only provides a single privileged action, and this enum only exist to ease future extensions.
public enum PrivilegedActionType: Int {

    /// A privileged action that deletes files from the file system.
    case deletion = 0
}
