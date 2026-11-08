package import Machine
import Parser
package import Parser_Machine_Program
package import Tagged


extension Machine.Parser.Failure {
    package enum Recovery {
        case continueWith(ID)
        case handleReady(Machine.Parser.Value.Handle)
        case propagate
    }
}
