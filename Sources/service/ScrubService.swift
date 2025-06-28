import Foundation
import ScrubCore

final class ScrubServiceDelegate: NSObject, NSXPCListenerDelegate, Sendable {
    func listener(_ listener: NSXPCListener,
                  shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: PrivilegedScrubProtocol.self)
        newConnection.exportedObject = PrivilegedScrubService()
        newConnection.resume()
        return true
    }
}

@objc
class PrivilegedScrubService: NSObject, PrivilegedScrubProtocol {
    func handle(
        _ request: ScrubCore.PrivilegedScrubRequest,
        completion: @escaping ((any Error)?) -> Void
    ) {
        var err: Error?

        do {
            try ActionFactory.create(using: request)
                .perform()
        } catch {
            err = error
        }

        completion(err)
    }
}

@main
struct ScrubService {
    private static let delegate = ScrubServiceDelegate()

    static func main() {
        let listener = NSXPCListener(machServiceName: ScrubServiceConstants.serviceName)
        listener.delegate = delegate
        listener.resume()

        // TODO: Let the service terminate after the task is finished.
        RunLoop.current.run()
    }
}
