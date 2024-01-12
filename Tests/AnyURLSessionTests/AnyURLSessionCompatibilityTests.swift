import Foundation
import XCTest
@testable import AnyURLSession

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class AnyURLSessionCompatibilityTests: XCTestCase {
  func testDefaultConstructionUsesURLSession() {
    let session: any AnyURLSession = URLSession.with(configuration: .default)
    XCTAssertNotNil(session as? URLSession, "The underlying type should be URLSession by default")
  }

  func testNonDefaultConstructionCorrectlyInitializesUnderlyingClass() throws {
    final class TestDelegate: NSObject, URLSessionDelegate {}

    let delegate = TestDelegate()
    let queue = OperationQueue()
    queue.name = "TestQueue"

    let session = URLSession.with(configuration: .default, delegate: delegate, delegateQueue: queue)

    let urlSession = try XCTUnwrap(session as? URLSession)

    XCTAssertEqual(urlSession.delegateQueue, queue)
    XCTAssertNotNil(urlSession.delegate as? TestDelegate)
  }
}
