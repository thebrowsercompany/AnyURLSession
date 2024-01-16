#if os(Windows) || os(Linux)
import Foundation
import XCTest
@testable import AnyURLSession

import class FoundationNetworking.URLSessionConfiguration

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
}
#endif
