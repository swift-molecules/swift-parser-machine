import Checkpoint
public import Cursor
import Iterator
public import Machine
import Parser
internal import Tagged

extension Machine.Parser {

    public typealias Program<
        Input: Cursor.`Protocol` & ~Copyable,
        Failure: Swift::Error
    > =
        Machine::Machine.Program<Leaf<Input, Failure>, Failure, Mode>
}
