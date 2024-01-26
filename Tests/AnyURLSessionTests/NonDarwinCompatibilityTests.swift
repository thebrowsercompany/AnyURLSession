#if os(Windows) || os(Linux)
import Foundation
import XCTest
@testable import AnyURLSession

import class FoundationNetworking.URLSessionConfiguration
import class FoundationNetworking.URLResponse
import struct FoundationNetworking.URLRequest

final class FakeGuts: URLSessionGuts {
  weak var delegate: URLSessionDelegate?
  weak var enclosingSession: URLSession?
  var queue: OperationQueue?

  var configuration: URLSessionConfiguration

  var _uploadTaskCalled: (() -> Void)?
  var _dataTaskWithClosureCalled: (() -> Void)?
  var _dataTaskCalled: (() -> Void)?
  var _invalidateAndCancelledCalled: (() -> Void)?
  var _finishTasksAndInvalidateCalled: (() -> Void)?
  var _updateInternalSessionCalled: (() -> Void)?

  init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?) {
    self.configuration = configuration
    self.delegate = delegate
    self.queue = queue
  }

  func uploadTask(with request: URLRequest, fromFile file: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionUploadTask {
    _uploadTaskCalled?()
    return URLSessionUploadTask()
  }

  func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
    _dataTaskWithClosureCalled?()
    return URLSessionDataTask()
  }

  func dataTask(with request: URLRequest) -> URLSessionDataTask {
    _dataTaskCalled?()
    return URLSessionDataTask()
  }

  func invalidateAndCancel() {
    _invalidateAndCancelledCalled?()
  }

  func finishTasksAndInvalidate() {
    _finishTasksAndInvalidateCalled?()
  }

  func updateInternalSession(_ session: URLSession) {
    enclosingSession = session
    _updateInternalSessionCalled?()
  }
}

final class NonDarwinCompatibilityTests: XCTestCase {
  func testDefaultConstruction() async {
    let configuration = URLSessionConfiguration.default
    configuration.identifier = "reimplementation"

    await withDependencies({
      $0.gutsFactory = { (config, _, _) in
        XCTAssertEqual(config, configuration)
        XCTAssertEqual(config.identifier, configuration.identifier)

        return MockGuts(configuration: config, delegate: nil, delegateQueue: nil)
      }
    }, operation: {
          _ = URLSession(configuration: configuration)
    })
  }

  func testDelegateAndQueueGetSet() async {
    final class TestDelegate: NSObject, URLSessionDataDelegate {}

    let testDelegate = TestDelegate()
    let testQueue = OperationQueue()

    await withDependencies({
      $0.gutsFactory = { (config, delegate, queue) in
        XCTAssertNotNil(delegate as? TestDelegate)
        XCTAssertEqual(queue, testQueue)

        return MockGuts(configuration: config, delegate: delegate, delegateQueue: queue)
      }
    }, operation: {
      let session = URLSession(configuration: .default, delegate: testDelegate, delegateQueue: testQueue)

      XCTAssertNotNil(session._guts as? MockGuts)
    })
  }

  func testGutsAreCalledForURLSessionInterface() async throws {
    final class TestDelegate: NSObject, URLSessionDataDelegate {}

    let testDelegate = TestDelegate()
    let testQueue = OperationQueue()

    let dataTaskWithClosureCalled = LockIsolated(false)
    let dataTaskCalled = LockIsolated(false)
    let uploadTaskCalled = LockIsolated(false)
    let invalidateAndCancelCalled = LockIsolated(false)
    let finishTasksAndInvalidateCalled = LockIsolated(false)
    let updateInternalSessionCalled = LockIsolated(false)

    try await withDependencies({
      $0.gutsFactory = { (config, delegate, queue) in
        let fakeGuts = FakeGuts(configuration: config, delegate: delegate, delegateQueue: queue)

        fakeGuts._dataTaskWithClosureCalled = {
          dataTaskWithClosureCalled.setValue(true)
        }

        fakeGuts._dataTaskCalled = {
          dataTaskCalled.setValue(true)
        }

        fakeGuts._uploadTaskCalled = {
          uploadTaskCalled.setValue(true)
        }

        fakeGuts._invalidateAndCancelledCalled = {
          invalidateAndCancelCalled.setValue(true)
        }

        fakeGuts._finishTasksAndInvalidateCalled = {
          finishTasksAndInvalidateCalled.setValue(true)
        }

        fakeGuts._updateInternalSessionCalled = {
          updateInternalSessionCalled.setValue(true)
        }

        return fakeGuts
      }
    }, operation: {
      let session = URLSession(configuration: .default, delegate: testDelegate, delegateQueue: testQueue)
      let request = URLRequest(url: try XCTUnwrap(URL(string: "https://arc.net")))

      let file = try XCTUnwrap(URL(fileURLWithPath: "C:\temp"))

      _ = session.uploadTask(with: request, fromFile: file, completionHandler: { _, _, _ in })
      _ = session.dataTask(with: request, completionHandler: {_, _, _ in })

      session.invalidateAndCancel()
      session.finishTasksAndInvalidate()

      let guts = try XCTUnwrap(session._guts as? FakeGuts)

      XCTAssertNotNil(guts.delegate as? TestDelegate)
      XCTAssertEqual(guts.queue, testQueue)
      XCTAssertTrue(dataTaskWithClosureCalled.value)
      XCTAssertTrue(uploadTaskCalled.value)
      XCTAssertTrue(invalidateAndCancelCalled.value)
      XCTAssertTrue(finishTasksAndInvalidateCalled.value)

      XCTAssertFalse(dataTaskCalled.value)
      _ = session.dataTask(with: request)
      XCTAssertTrue(dataTaskCalled.value)

      XCTAssertEqual(session, try XCTUnwrap(guts.enclosingSession))
    })
  }

  func testTasksAreCreatedByDefaultDoNothing() async throws {
    final class TestDelegate: NSObject, URLSessionDataDelegate {}

    let testDelegate = TestDelegate()
    let testQueue = OperationQueue()

    try await withDependencies({
      $0.gutsFactory = { (config, delegate, queue) in
        return MockGuts(configuration: config, delegate: delegate, delegateQueue: queue)
      }
    }, operation: {
      let session = URLSession(configuration: .default, delegate: testDelegate, delegateQueue: testQueue)
       let request = URLRequest(url: try XCTUnwrap(URL(string: "https://arc.net")))

      let file = try XCTUnwrap(URL(fileURLWithPath: "C:\temp"))

      let uploadTask = session.uploadTask(with: request, fromFile: file, completionHandler: { _, _, _ in })
      let dataTask = session.dataTask(with: request, completionHandler: {_, _, _ in })

      XCTAssertEqual(uploadTask.state, .suspended)
      XCTAssertEqual(dataTask.state, .suspended)

      uploadTask.resume()
      dataTask.resume()

      XCTAssertEqual(uploadTask.state, .suspended)
      XCTAssertEqual(dataTask.state, .suspended)

      uploadTask.cancel()
      dataTask.cancel()

      XCTAssertEqual(uploadTask.state, .suspended)
      XCTAssertEqual(dataTask.state, .suspended)
    })
  }
}
#endif
