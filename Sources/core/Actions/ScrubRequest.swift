import Foundation

/// An request for a non-privileged action.
public struct ScrubRequest {

    /// Type of the action to perform.
    let actionType: ActionType

    /// Name or part of the target file name to clean.
    let keyword: String

    /// A boolean value that indicates whether or not user confirmation is needed before performing the action.
    let force: Bool

    /// Optional path to the spaces file.
    let spacesFile: URL?

    public init(actionType: ActionType, targetFile: String, force: Bool, spacesFile: URL? = nil) {
        self.actionType = actionType
        self.keyword = targetFile
        self.spacesFile = spacesFile
        self.force = force
    }
}
