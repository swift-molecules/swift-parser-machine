package import Machine
import Parser
package import Parser_Machine_Program
package import Tagged

extension Machine.Parser {
    package enum Failure {}
}

extension Machine.Parser.Failure {
}

extension Machine.Parser.Failure.Recovery {
    package typealias ID = Tagged<Machine.Parser.Failure.Recovery, Ordinal>
}
