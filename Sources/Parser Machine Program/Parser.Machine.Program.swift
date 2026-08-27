public import Input
public import Machine
import Parser
internal import Tagged

extension Parser.Machine {

    public typealias Program<
        Input: Input.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    > =
        Machine.Machine.Program<Leaf<Input, Failure>, Failure, Mode>
}
