#if os(Linux) || os(Windows)
import class Foundation.OperationQueue
import class FoundationNetworking.URLSessionConfiguration

public struct Dependencies: Sendable {
  public static let current = LockIsolated(Dependencies?.none)

  /// Used to construct the internals of the re-implemented URLSession
  /// If you use this package you *must* set this otherwise you will crash.
  public var gutsFactory: @Sendable (URLSessionConfiguration, URLSessionDelegate?, OperationQueue?) -> URLSessionGuts
}
#endif
