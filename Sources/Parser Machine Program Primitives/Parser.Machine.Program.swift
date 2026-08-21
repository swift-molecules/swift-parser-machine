public import Input_Primitives
public import Machine_Primitives
import Parser_Primitives
internal import Tagged_Primitives

extension Parser.Machine {

    public typealias Program<
        Input: Input_Primitives.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    > =
        Machine_Primitives.Machine.Program<Leaf<Input, Failure>, Failure, Mode>
}
