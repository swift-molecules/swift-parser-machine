public import Input
public import Machine
public import Parser_Machine_Program
import Parser

extension Parser.Machine {

    public typealias Frame<
        Input: Input.Input.`Protocol` & ~Copyable,
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
