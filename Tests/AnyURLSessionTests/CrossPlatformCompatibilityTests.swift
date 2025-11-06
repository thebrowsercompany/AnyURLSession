import Foundation
import XCTest
@testable import AnyURLSession

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class CrossPlatformCompatibilityTests: XCTestCase {
  func testForcedToSpecifyModuleToDisambiguate() async {
    #if os(Linux) || os(Windows) || os(Android)
    _ = FoundationNetworking.URLSession(configuration: .default)

    await withDependencies({
      $0.gutsFactory = { (config, _, _) in
        return MockGuts(configuration: config, delegate: nil, delegateQueue: nil)
      }
    }, operation: {
      _ = AnyURLSession.URLSession(configuration: .default)
    })
    #else
    _ = URLSession(configuration: .default)
    #endif
  }
}

