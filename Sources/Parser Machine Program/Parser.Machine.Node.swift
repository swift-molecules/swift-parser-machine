public import Input
public import Machine
import Parser
internal import Tagged

extension Parser.Machine {

    public typealias Node<
        Input: Input.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    > =
        Machine.Machine.Node<Leaf<Input, Failure>, Failure, Mode>

    public struct Leaf<Input: Input.Input.`Protocol` & ~Copyable, Failure: Swift.Error> {
        @usableFromInline
        package let run: (inout Input) throws(Failure) -> Value

        @usableFromInline
        package init(_ run: @escaping (inout Input) throws(Failure) -> Value) {
            self.run = run
        }
    }
}
