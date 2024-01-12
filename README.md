# AnyURLSession

A package that outlines the minimal shape of `URLSession` to ease reimplementation across different platforms which might need to supply their own networking.

By default the construction of the `AnyURLSession` protocol will create a `URLSession` instance.
