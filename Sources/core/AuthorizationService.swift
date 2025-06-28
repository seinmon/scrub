import Foundation

/// Represents the authorization reference from an external process.
class ExternalAuthorizationReference: NSSecureCoding {
    static var supportsSecureCoding: Bool {
        return true
    }

    func encode(with coder: NSCoder) {
        coder.encode(authRequestRight.rawValue, forKey: "extAuthRight")
        let extAuthData = withUnsafeBytes(of: externalAuthForm) { Data($0) }
        coder.encode(extAuthData, forKey: "extAuth")
    }

    required init?(coder: NSCoder) {
        let rawExtAuthRight = coder.decodeInteger(forKey: "extAuthRight")

        guard let extAuthRight = AuthorizationRequestRight(rawValue: rawExtAuthRight) else {
            return nil
        }

        guard let data = coder.decodeObject(of: NSData.self, forKey: "extAuth") as Data?,
              data.count == MemoryLayout<AuthorizationExternalForm>.size else {
            return nil
        }

        self.authRequestRight = extAuthRight
        self.externalAuthForm = data.withUnsafeBytes { $0.load(as: AuthorizationExternalForm.self) }
    }

    /// Requested right for authorization.
    let authRequestRight: AuthorizationRequestRight

    /// External authorization form that can be used to validate authorization of rights.
    let externalAuthForm: AuthorizationExternalForm

    fileprivate init(authRequestRight: AuthorizationRequestRight,
                     externalAuthForm: AuthorizationExternalForm) {
        self.authRequestRight = authRequestRight
        self.externalAuthForm = externalAuthForm
    }
}

/// Authorization right needed to perform a certain privileged `Scrub` action on the system.
enum AuthorizationRequestRight: Int {

    /// Authentication request to perform an uninstaller action.
    case uninstaller = 0

    /// Authentication request to perform a cleaner action.
    case cleaner = 1

    /// Value of the right required to complete the provided request.
    fileprivate var right: String {
        switch self {
        case .uninstaller:
            return "com.seinmon.scrub.actions.uninstaller"

        case .cleaner:
            return "com.seinmon.scrub.actions.cleaner"
        }
    }
}

/// Authorize the user to run a privileged task on the system.
struct AuthorizationService {

    /// External form of the authorization reference, to send to the privileged service.
    private(set) var externalForm: AuthorizationExternalForm

    /// The type of requested right, which is used to generate `ExternalAuthorizationReference`.
    private let authRequestRight: AuthorizationRequestRight

    /// The right that was requested by the authorization requester.
    private var right: AuthorizationItem

    /// Complete set of rights to use for authorization of the user.
    private lazy var completeRights: AuthorizationRights = {
        var rights = AuthorizationRights()

        withUnsafeMutablePointer(to: &right) { right in
            rights.count = 1
            rights.items = UnsafeMutablePointer(right)
        }

        return rights
    }()

    private var authFlags: AuthorizationFlags {
        return [.preAuthorize, .interactionAllowed, .extendRights]
    }

    /// Errors that can occur during authorization of a user with rights.
    enum AuthorizationError: Error, LocalizedError {

        /// Raised when a valid right cannot be generated from the request.
        case failedToProcessRequestRight

        /// Raised when authorization is unsuccessful.
        case failedToAuthorize(OSStatus)

        /// Raised when authorization reference is null, despite successful authorization.
        case unexpectedAuthorizationReference

        /// Raised due to failure of generating external form of the authorization data.
        case failedToGetExtenalForm(OSStatus)

        /// Raised due to failure of generating authorization reference from external form.
        case failedToGetReferenceFromExtenalForm(OSStatus)

        // Just to avoid repeating myself, and enable easier changes in the future.
        private var errorIntro: String {
            return "Authorization Error"
        }

        private var createBugReport: String {
            return """

                This is an indicator of internal errors. Please create a bug report at: \
                https://github.com/seinmon/scrub/issues
                """
        }

        var errorDescription: String? {
            switch self {
            case .failedToProcessRequestRight:
                return """
                    \(errorIntro): Requested action cannot perform a privileged operation.
                    \(createBugReport)
                    """

            case .failedToAuthorize(let status):
                return """
                    \(errorIntro): Failed to authorize the user with error code: \(status)
                    """

            case .unexpectedAuthorizationReference:
                return """
                    \(errorIntro): Received unexpected null value for authorization data.
                    \(createBugReport)
                    """

            case .failedToGetExtenalForm(let status):
                return """
                    \(errorIntro): Failed to validate authorization data. No authorization data \
                    has been provided. \(status)
                    """

            case .failedToGetReferenceFromExtenalForm(let status):
                return """
                    \(errorIntro): Failed to access authorization data of the caller \
                    process. \(status).
                    \(createBugReport)
                    """
            }
        }
    }

    /// Initialize `AuthorizationService` with certain rights.
    ///
    /// Use this initializer if no previous authorization has been done. If your goal is to validate a previous authorization from an external
    /// process, use:
    /// ```
    /// init(with externalRef: ExternalAuthorizationReference) throws
    /// ```
    ///
    /// - Parameters:
    ///    - request: `AuthorizationRequestRight` that indicates which right should be authorized.
    ///
    init(for request: AuthorizationRequestRight) throws {
        self.authRequestRight = request
        self.externalForm = AuthorizationExternalForm()

        guard let rightName = NSString(string: request.right).utf8String else {
            throw AuthorizationError.failedToProcessRequestRight
        }

        self.right = AuthorizationItem(name: rightName, valueLength: 0, value: nil, flags: 0)
    }

    /// Initialize `AuthorizationService` with certain rights and a pre-existing authorization from an external process.
    ///
    /// - Parameters:
    ///    - externalRef: Representation of authorization carried out by an external process.
    init(with externalRef: ExternalAuthorizationReference) throws {
        try self.init(for: externalRef.authRequestRight)
        self.externalForm = externalRef.externalAuthForm
    }

    /// Authorize a user with certain rights to call a privileged service.
    ///
    /// - Returns: An external form of authorization reference to use by the privileged service.
    ///
    /// - Throws: `AuthorizationError` in case of unsuccessful authorization.
    mutating func authorizeForPrivilegedServices() throws -> ExternalAuthorizationReference {
        var authRef: AuthorizationRef?

        let authStatus = AuthorizationCreate(&completeRights, nil, authFlags, &authRef)

        guard authStatus == errAuthorizationSuccess else {
            throw AuthorizationError.failedToAuthorize(authStatus)
        }

        // This should never fail.
        guard let authRef = authRef else {
            throw AuthorizationError.unexpectedAuthorizationReference
        }

        let externalFormStatus = AuthorizationMakeExternalForm(authRef, &externalForm)

        guard externalFormStatus == errAuthorizationSuccess else {
            throw AuthorizationError.failedToGetExtenalForm(externalFormStatus)
        }

        return ExternalAuthorizationReference(authRequestRight: self.authRequestRight,
                                              externalAuthForm: self.externalForm)
    }

    /// Validate the user authorization with correct rights to perform a privileged task.
    ///
    /// - Throws: `AuthorizationError` in case of validation failure.
    mutating func validate() throws {
        var authRef: AuthorizationRef? = nil

        let authRefCreateStatus = AuthorizationCreateFromExternalForm(&externalForm, &authRef)

        guard authRefCreateStatus == errAuthorizationSuccess else {
            throw AuthorizationError.failedToGetReferenceFromExtenalForm(authRefCreateStatus)
        }

        guard let authRef = authRef else {
            throw AuthorizationError.unexpectedAuthorizationReference
        }

        let authStatus = AuthorizationCopyRights(authRef, &completeRights, nil, authFlags, nil)

        guard authStatus == errAuthorizationSuccess else {
            throw AuthorizationError.failedToAuthorize(authStatus)
        }
    }
}
