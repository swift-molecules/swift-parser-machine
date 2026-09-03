public import Checkpoint
public import Cursor
public import Iterator
public import Iterator_Protocol
public import Machine
public import Parser_Machine_Program
import Parser

extension Parser.Machine {

    public typealias Frame<
        Input: Cursor.`Protocol` & ~Copyable,
        Failure: Swift.Error
    > = Machine.Machine.Frame<
        Node<Input, Failure>.ID,
        Input.Checkpoint,
        Mode,
        Failure,
        Extra<Input.Checkpoint>
    >

    public enum Extra<Checkpoint> {

        case memoization(node: Ordinal, startPosition: Checkpoint)
    }
}
