import Foundation

/// Authorization right needed to perform a certain privileged `Scrub` action on the system.
enum AuthorizationRequestRight {

    /// Authentication request to perform a destructive action.
    case destructive

    /// Value of the right required to complete the provided request.
    fileprivate var right: String {
        switch self {
        case .destructive:
            return "com.seinmon.scrub.actions.destructive"
        }
    }
}

/// Authorize the user to run a privileged task on the system.
struct AuthorizationService {
    private(set) var externalForm: AuthorizationExternalForm

    private var right: AuthorizationItem

    private lazy var completeRights: AuthorizationRights = {
        var rights = AuthorizationRights()

        withUnsafeMutablePointer(to: &right) { right in
            rights.count = 1
            rights.items = UnsafeMutablePointer(right)
        }

        return rights
    }()

    enum AuthorizationError: Error, LocalizedError {
        case failedToProcessRequestRight

        var errorDescription: String? {
            switch self {
            case .failedToProcessRequestRight:
                return "Failed to generate an authorization right from the provided request right."
            }
        }
    }

    init(for request: AuthorizationRequestRight) throws {
        self.externalForm = AuthorizationExternalForm()

        guard let rightName = NSString(string: request.right).utf8String else {
            throw AuthorizationError.failedToProcessRequestRight
        }

        self.right = AuthorizationItem(name: rightName, valueLength: 0, value: nil, flags: 0)
    }

    public mutating func authorize() {
        var authRef: AuthorizationRef?

        let authStatus = AuthorizationCreate(&completeRights,
                                             nil,
                                             [.preAuthorize, .interactionAllowed, .extendRights],
                                             &authRef)

        guard authStatus == errAuthorizationSuccess, let authRef = authRef else {
            fatalError("Failed with \(authStatus)")
        }

        let externalFormStatus = AuthorizationMakeExternalForm(authRef, &externalForm)

        guard externalFormStatus == errAuthorizationSuccess else {
            fatalError("Failed with \(externalFormStatus)")
        }
    }
}
