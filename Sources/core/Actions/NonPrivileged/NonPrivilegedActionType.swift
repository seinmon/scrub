import Foundation

/// A representation of possible actions.
///
/// Currently, `scrub` only provides a single privileged action, and this enum only exist to ease future extensions.
public enum ActionType {

    /// An action that deletes files from the file system.
    case cleaner

    /// An action that searches for the files on the file system.
    case searcher

    /// An action that deletes an Application and its files from the file system.
    case uninstaller
}
