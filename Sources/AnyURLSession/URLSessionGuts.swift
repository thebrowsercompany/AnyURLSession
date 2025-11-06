#if os(Linux) || os(Windows) || os(Android)
import Foundation

import class FoundationNetworking.URLSessionConfiguration
import class FoundationNetworking.URLResponse
import struct FoundationNetworking.URLRequest

/// URLSessionGuts is responsible for doing the actual work when someone calls into a URLSession function that we've
/// made available in this re-implementation.
public protocol URLSessionGuts: Sendable {
  var configuration: URLSessionConfiguration { get }

  init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?)
  func uploadTask(with request: URLRequest, fromFile file: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask

  func dataTask(with request: URLRequest) -> URLSessionDataTask
  func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask

  func invalidateAndCancel()
  func finishTasksAndInvalidate()

  // Used as an opportunity for whatever guts to receive the instance of URLSession that was just created.
  func updateInternalSession(_ session: URLSession)
}

#endif
