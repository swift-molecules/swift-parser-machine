package import Machine
package import Parser_Machine_Program
import Parser
package import Tagged

extension Machine.Parser {
    package enum Failure {}
}

extension Machine.Parser.Failure {
    package enum Recovery {
        case continueWith(ID)
        case handleReady(Machine.Parser.Value.Handle)
        case propagate
    }
}

extension Machine.Parser.Failure.Recovery {
    package enum Tag {}

    package typealias ID = Tagged<Tag, Ordinal>
}
