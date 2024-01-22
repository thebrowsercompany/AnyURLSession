#if os(Linux) || os(Windows)
import Foundation

import class FoundationNetworking.URLSessionConfiguration
import class FoundationNetworking.URLResponse
import struct FoundationNetworking.URLRequest

import AnyURLSession

final class MockGutsSessionUploadTask: URLSessionUploadTask {
  private var _state: URLSessionTask.State = .suspended

  override var state: URLSessionTask.State {
    get {
      return _state
    }
  }
  override func resume() {
    // Do nothing, but make sure we can override this
  }

  override func cancel() {
    // Do nothing, but make sure we can override this
  }

  func _updateInternalState(new: URLSessionTask.State) {
    _state = new
  }
}

final class MockGuts: URLSessionGuts {
  var configuration: URLSessionConfiguration

  init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?) {
    self.configuration = configuration
  }
  func uploadTask(with request: URLRequest, fromFile file: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
    let task = MockGutsSessionUploadTask()

    return task
  }

  func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
    URLSessionDataTask()
  }

  func dataTask(with request: URLRequest) -> URLSessionDataTask {
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
