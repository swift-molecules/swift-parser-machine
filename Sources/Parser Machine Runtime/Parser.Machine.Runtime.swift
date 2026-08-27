internal import Parser_Machine_Program
import Parser

extension Parser.Machine {
    package enum Runtime {}
}

extension Parser.Machine.Runtime {
    package enum Error: Swift.Error, Sendable {
        case depthExceeded(limit: Int)
        case typeMismatch
        case internalError(String)
        case cachedFailure
    }
}
