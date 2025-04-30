import Foundation

/// Represents the authorization reference from an external process.
public struct ExternalAuthorizationReference {

    /// Requested right for authorization.
    internal let authRequestRight: AuthorizationRequestRight

    /// External authorization form that can be used to validate authorization of rights.
    internal let externalAuthForm: AuthorizationExternalForm

    internal init(authRequestRight: AuthorizationRequestRight,
                  externalAuthForm: AuthorizationExternalForm) {
        self.authRequestRight = authRequestRight
        self.externalAuthForm = externalAuthForm
    }
}
