import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol AnyDataTask {
  var state: URLSessionTask.State { get }
  func resume()
  func cancel()
}

public protocol AnyUploadTask: AnyDataTask {}

public protocol AnyURLSession {
  associatedtype DataTaskType: AnyDataTask
  associatedtype UploadTaskType: AnyUploadTask

  func uploadTask(with request: URLRequest, fromFile file: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> UploadTaskType
  func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> DataTaskType

  func invalidateAndCancel()
  func finishTasksAndInvalidate()

  // We can't specify the initializer required due to the interplay of URLSession being an NSObject so instead
  // we create a factory function that's required to be implemented and just provide a default implementation
  // which will supply a URLSession configured with the passed in parameters.
  static func with(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue: OperationQueue?) -> any AnyURLSession
}
