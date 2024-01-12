import Foundation

#if os(Linux) || os(Windows)
import FoundationNetworking
#endif

extension URLSessionDataTask: AnyDataTask {}
extension URLSessionUploadTask: AnyUploadTask {}

// Give the built in `URLSession` conformance to HTTPSession so that it can easily be used
extension URLSession: AnyURLSession {
    public static func with(configuration: URLSessionConfiguration, delegate: (any URLSessionDelegate)? = nil, delegateQueue: OperationQueue? = nil) -> any AnyURLSession {
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)
    }
}
