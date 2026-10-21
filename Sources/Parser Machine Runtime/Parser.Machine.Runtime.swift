import Machine
import Parser
internal import Parser_Machine_Program

extension Machine.Parser {
    package enum Runtime {}
}

extension Machine.Parser.Runtime {
    package enum Error: Swift::Error, Sendable {
        case depthExceeded(limit: Int)
        case typeMismatch
        case internalError(String)
        case cachedFailure
    }
}
