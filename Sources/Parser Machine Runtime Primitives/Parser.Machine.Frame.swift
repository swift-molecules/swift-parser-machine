public import Input_Primitives
public import Machine_Primitives
public import Parser_Machine_Program_Primitives
import Parser_Primitives

extension Parser.Machine {

    public typealias Frame<
        Input: Input_Primitives.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    > = Machine_Primitives.Machine.Frame<
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
