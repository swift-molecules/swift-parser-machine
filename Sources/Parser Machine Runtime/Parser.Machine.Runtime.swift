package import Machine
internal import Parser_Machine_Program
import Parser

extension Machine.Parser {
    package enum Runtime {}
}

extension Machine.Parser.Runtime {
    package enum Error: Swift.Error, Sendable {
        case depthExceeded(limit: Int)
        case typeMismatch
        case internalError(String)
        case cachedFailure
    }
}
