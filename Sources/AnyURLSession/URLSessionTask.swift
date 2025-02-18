#if os(Linux) || os(Windows) || os(Android)
import class Foundation.NSObject

// Reimplemented interfaces for URLSession that will allow for stubbing/subclassing
// https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/FoundationNetworking/URLSession/URLSessionTask.swift\
open class URLSessionTask: NSObject {
  open var state: URLSessionTask.State {
    get {
      .suspended
    }
  }
  open func resume() {}
  open func cancel() {}
}

extension URLSessionTask {
    public enum State : Int {
        case running
        case suspended
        case canceling
        case completed
    }
}

open class URLSessionDataTask: URLSessionTask {}
open class URLSessionUploadTask: URLSessionDataTask {}
#endif
