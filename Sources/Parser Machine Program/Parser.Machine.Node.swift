public import Checkpoint
public import Cursor
public import Iterator
public import Iterator_Protocol
public import Machine
import Parser
internal import Tagged

extension Parser.Machine {

    public typealias Node<
        Input: Cursor.`Protocol` & ~Copyable,
        Failure: Swift.Error
    > =
        Machine.Machine.Node<Leaf<Input, Failure>, Failure, Mode>

    public struct Leaf<Input: Cursor.`Protocol` & ~Copyable, Failure: Swift.Error> {
        @usableFromInline
        package let run: (inout Input) throws(Failure) -> Value

        @usableFromInline
        package init(_ run: @escaping (inout Input) throws(Failure) -> Value) {
            self.run = run
        }
    }
}
