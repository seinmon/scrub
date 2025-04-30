import Foundation

/// An abstract action that can be used by the privileged `scrub-service`.
///
/// This action simply takes a set of file `URL`s to operate on. It requires a valid `ExternalAuthorizationReference` to be
/// initialized, which ensures it can only be used by the privileged `scrub-service`.
public class PrivilegedAction: Action {
    let files: Set<URL>
    var authService: AuthorizationService

    public init(externalAuthRef: ExternalAuthorizationReference, targetFiles: Set<URL>) throws {
        self.files = targetFiles
        self.authService = try AuthorizationService(with: externalAuthRef)
    }

    public func perform() throws {
        fatalError("Cannot perform an abstract action.")
    }
}
