import Foundation

/// An request for a privileged action for `scrub-service`.
@objc
public class PrivilegedScrubRequest: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool {
        return true
    }

    public func encode(with coder: NSCoder) {
        coder.encode(actionType.rawValue, forKey: "actionType")
        externalAuthReference.encode(with: coder)

        // NSURL natively support NSSecureCoding.
        coder.encode(targetFile as NSURL, forKey: "targetFile")
    }

    public required init?(coder: NSCoder) {
        let opcode = coder.decodeInteger(forKey: "actionType")
        guard let actionType = PrivilegedActionType(rawValue: opcode) else {
            return nil
        }

        guard let extAuthRef = ExternalAuthorizationReference(coder: coder) else {
            return nil
        }

        guard let url = coder.decodeObject(of: NSURL.self, forKey: "targetFile") as? URL else {
            return nil
        }

        self.actionType = actionType
        self.externalAuthReference = extAuthRef
        self.targetFile = url
    }

    /// Type of the action to perform.
    let actionType: PrivilegedActionType

    /// External authorization reference that is used to validate user authorization.
    let externalAuthReference: ExternalAuthorizationReference

    /// Target file of the operation.
    let targetFile: URL

    init(actionType: PrivilegedActionType,
         externalAuthReference: ExternalAuthorizationReference,
         targetFile: URL) {
        self.actionType = actionType
        self.externalAuthReference = externalAuthReference
        self.targetFile = targetFile
    }
}
