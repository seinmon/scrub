import Foundation

struct PrivilegedScrub {
    private let connection: NSXPCConnection

    init() {
        self.connection = NSXPCConnection(machServiceName: ScrubServiceConstants.serviceName)
        self.connection.remoteObjectInterface = NSXPCInterface(with: PrivilegedScrubProtocol.self)
        self.connection.resume()
    }

    func send(_ request: PrivilegedScrubRequest) {
        if let service = connection.remoteObjectProxy as? PrivilegedScrubProtocol {
            service.handle(request) { err in
                if let err = err {
                    print("Failed with error: \(err.localizedDescription)")
                }
#if DEBUG
                if err == nil {
                    print("Done.")
                }
#endif // DEBUG
            }
        }
    }
}
