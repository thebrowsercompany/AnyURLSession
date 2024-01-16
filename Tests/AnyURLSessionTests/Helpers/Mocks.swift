#if os(Linux) || os(Windows)
import Foundation

import class FoundationNetworking.URLSessionConfiguration
import class FoundationNetworking.URLResponse
import struct FoundationNetworking.URLRequest

@testable import AnyURLSession

final class MockGuts: URLSessionGuts {
  init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?) {}
  func uploadTask(with request: URLRequest, fromFile file: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
    URLSessionUploadTask()
  }

  func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
    URLSessionDataTask()
  }

  func invalidateAndCancel() {}
  func finishTasksAndInvalidate() {}
}

extension Dependencies {
  static var mock: Self {
    Dependencies(
      gutsFactory: { (config, delegate, queue) in
        MockGuts(configuration: config, delegate: delegate, delegateQueue: queue)
      }
    )
  }
}

func withDependencies(
  _ mutation: (inout Dependencies) throws -> Void,
  operation: () async throws -> Void
) async rethrows {
  let current = Dependencies.current.value ?? .mock
  var copy = current
  try mutation(&copy)
  Dependencies.current.withValue { [copy] in $0 = copy }
  defer { Dependencies.current.setValue(current) }
  try await operation()
}
#endif
