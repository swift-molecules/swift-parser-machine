package import Machine
package import Parser_Machine_Program
import Parser
package import Tagged

extension Parser.Machine {
    package enum Failure {}
}

extension Parser.Machine.Failure {
    package enum Recovery {
        case continueWith(ID)
        case handleReady(Parser.Machine.Value.Handle)
        case propagate
    }
}

extension Parser.Machine.Failure.Recovery {
    package enum Tag {}

    package typealias ID = Tagged<Tag, Ordinal>
}
