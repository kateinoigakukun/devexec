# devexec

A simple tool to help switching PATH and execute command in the PATH

```sh
# Register PATH modes
$ devexec add swift-lto-work-release path/to/swift-source/build/Ninja-ReleaseAssert/swift-macosx-x86_64/bin/
$ devexec add swift-lto-work-debug path/to/swift-source/build/Ninja-DebugAssert/swift-macosx-x86_64/bin/


$ devexec list
swift-lto-work-release
swift-lto-work-debug

# Exec command in PATH
$ devexec swift-lto-work-release which swiftc
path/to/swift-source/build/Ninja-ReleaseAssert/swift-macosx-x86_64/bin/swiftc
$ devexec swift-lto-work-release which swiftc
path/to/swift-source/build/Ninja-DebugAssert/swift-macosx-x86_64/bin/swiftc
```
