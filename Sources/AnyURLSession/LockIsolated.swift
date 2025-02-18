#if os(Linux) || os(Windows) || os(Android)
import class Foundation.NSRecursiveLock

// A lightweight copy/rebuild of the LockIsolated class from Concurrency Extras
// https://github.com/pointfreeco/swift-concurrency-extras/blob/main/Sources/ConcurrencyExtras/LockIsolated.swift
public final class LockIsolated<Value>: @unchecked Sendable {
  private var _value: Value
  private let lock = NSRecursiveLock()

  public init(_ value: @autoclosure @Sendable () throws -> Value) rethrows {
    self._value = try value()
  }

  public func withValue<T: Sendable>(_ operation: @Sendable (inout Value) throws -> T) rethrows -> T {
    try self.lock.sync {
      var value = self._value
      defer { self._value = value }
      return try operation(&value)
    }
  }

  public func setValue(_ newValue: @autoclosure @Sendable () throws -> Value) rethrows {
    try self.lock.sync { self._value = try newValue() }
  }
}

extension LockIsolated where Value: Sendable {
  public var value: Value {
    self.lock.sync { self._value }
  }
}

extension NSRecursiveLock {
  @inlinable @discardableResult
  public func sync<R>(work: () throws -> R) rethrows -> R {
    self.lock()
    defer { self.unlock() }
    return try work()
  }
}
#endif
