import Foundation

/// Manages connections to the `scrub-service` and performs privileged actions.
struct PrivilegedScrub {
    private let connection: NSXPCConnection

    init() {
        self.connection = NSXPCConnection(machServiceName: ScrubServiceConstants.serviceName)
        self.connection.remoteObjectInterface = NSXPCInterface(with: PrivilegedScrubProtocol.self)
        self.connection.resume()
    }

    /// Send a request to the `scrub-service`.
    ///
    /// - Parameters:
    ///    - request: A request describing the desired privileged action.
    func send(_ request: PrivilegedScrubRequest, semaphore: DispatchSemaphore) {
        if let service = connection.remoteObjectProxy as? PrivilegedScrubProtocol {
            service.handle(request) { [semaphore] err in
                if let err = err {
                    print("Failed with error: \(err.localizedDescription)")
                }

#if DEBUG
                if err == nil {
                    print("Done.")
                }
#endif // DEBUG

                semaphore.signal()
            }
        }
    }
}
