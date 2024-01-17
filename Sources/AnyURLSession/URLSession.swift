#if os(Linux) || os(Windows)
import class FoundationNetworking.CachedURLResponse
import class FoundationNetworking.HTTPURLResponse
import class FoundationNetworking.URLAuthenticationChallenge
import class FoundationNetworking.URLCredential
import class FoundationNetworking.URLResponse
import class FoundationNetworking.URLSessionConfiguration
import class FoundationNetworking.URLSessionTaskMetrics
import struct FoundationNetworking.URLRequest

import Foundation

extension URLSession {
  public enum DelayedRequestDisposition {
    case cancel
    case continueLoading
    case useNewRequest
  }
}

extension URLSession {
  public enum AuthChallengeDisposition: Int {
    case useCredential
    case performDefaultHandling
    case cancelAuthenticationChallenge
    case rejectProtectionSpace
  }

  public enum ResponseDisposition: Int {
    case cancel
    case allow

    @available(*, deprecated, message: "swift-anyurlsession doesn't currently support turning responses into downloads dynamically.")
    case becomeDownload

    @available(*, unavailable, message: "swift-anyurlsession doesn't support stream tasks.")
    case becomeStream
  }
}

open class URLSession: NSObject {
  internal private(set) var _guts: URLSessionGuts

  public init(configuration: URLSessionConfiguration) {
    _guts = Dependencies.current.value!.gutsFactory(configuration, nil, nil)
  }
  public init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?) {
    _guts = Dependencies.current.value!.gutsFactory(configuration, delegate, queue)
  }

  public func uploadTask(with request: URLRequest, fromFile file: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
    _guts.uploadTask(with: request, fromFile: file, completionHandler: completionHandler)
  }

  public func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
    _guts.dataTask(with: request, completionHandler: completionHandler)
  }

  public func dataTask(with request: URLRequest) -> URLSessionDataTask {
    _guts.dataTask(with: request)
  }

  public func invalidateAndCancel() {
    _guts.invalidateAndCancel()
  }

  public func finishTasksAndInvalidate() {
    _guts.finishTasksAndInvalidate()
  }
}

public protocol URLSessionDelegate: NSObjectProtocol {
  func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?)
  func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}

extension URLSessionDelegate {
  public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) { }
  public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) { }
}

public protocol URLSessionTaskDelegate : URLSessionDelegate {
  func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void)
  func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
  func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void)
  func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
  func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void)
  func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics)
}

extension URLSessionTaskDelegate {
  public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
    completionHandler(request)
  }

  public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    completionHandler(.performDefaultHandling, nil)
  }

  public func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
    completionHandler(nil)
  }

  public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {}
  public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {}
  public func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {}
  public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {}
}

public protocol URLSessionDataDelegate: URLSessionTaskDelegate {
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
  // Removed since the open source implementation originally from swift-corelibs-foundation doesn't support task conversion
  // func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask)
  // func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask)
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void)
}

extension URLSessionDataDelegate {
  public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {}
  public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {}
  public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {}
}
#endif
