import Foundation

@objc
public protocol PrivilegedScrubProtocol {
    func handle(_ request: PrivilegedScrubRequest, completion: @escaping (Error?) -> Void)
}
