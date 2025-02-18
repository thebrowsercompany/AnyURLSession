#if os(Linux) || os(Windows) || os(Android)
// Automatically export the imports that people will most likely require when
// using the AnyURLSession library in their project.
@_exported import class FoundationNetworking.HTTPURLResponse
@_exported import class FoundationNetworking.URLResponse
@_exported import class FoundationNetworking.URLSessionConfiguration
@_exported import struct FoundationNetworking.URLRequest
#endif
