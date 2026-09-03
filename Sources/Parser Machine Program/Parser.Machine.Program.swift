public import Checkpoint
public import Cursor
public import Iterator
public import Iterator_Protocol
public import Machine
import Parser
internal import Tagged

extension Parser.Machine {

    public typealias Program<
        Input: Cursor.`Protocol` & ~Copyable,
        Failure: Swift.Error
    > =
        Machine.Machine.Program<Leaf<Input, Failure>, Failure, Mode>
}
