import Foundation

/// An abstract action that can be used by the privileged `scrub-service`.
///
/// This action simply takes a set of file `URL`s to operate on. It requires a valid `ExternalAuthorizationReference` to be
/// initialized, which ensures it can only be used by the privileged `scrub-service`.
class PrivilegedAction: Action {

    /// Target of the action.
    let targetFile: URL

    /// Instance of `AuthorizationService`, which is used to validate the user's privilege.
    var authService: AuthorizationService

    init(externalAuthRef: ExternalAuthorizationReference, targetFile: URL) throws {
        self.targetFile = targetFile
        self.authService = try AuthorizationService(with: externalAuthRef)
    }

    public func perform() throws {
        fatalError("Cannot perform an abstract action.")
    }
}
