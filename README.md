# AnyURLSession

AnyURLSession is a set of objects, and protocols that mirror pieces of `URLSession` with a key difference that the reimplementation of `URLSession` will call into a dependency system which allows you to specify your own implementation powered by the interfaces.

A an example of why you might want to use this library is because you are already packaging a networking stack that you'd like all of your dependencies to use. Chances are these depenedncies are already using `URLSession`, adding this package to these libraries will let you switch out the networking stack while maintaining URLSession conformance.

A basic use case could look like the following...


```swift
// Package A
import AnyURLSession

final class ChromiumURLSessionGuts: URLSessionGuts {}

AnyURLSession.Dependencies.current.setValue(
  Dependencies(gutsFactory: { (config, delegate, queue) in
    ChromiumURLSessionGuts(configuration: config, delegate: delegate, delegateQueue: queue)
  })
)


// Package B (which Package A includes)
import AnyURLSession

let session = AnyURLSession.URLSession(configuration: ..., delegate: ..., delegateQueue: ...)
```

When using the `URLSession` provided from `AnyURLSession` calls from the session interface will be routed to whatever the session guts that you've specified.
