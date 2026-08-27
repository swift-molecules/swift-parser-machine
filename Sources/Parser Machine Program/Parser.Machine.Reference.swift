public import Input
public import Machine
import Parser

extension Parser.Machine {

    public struct Reference<
        Input: Input.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error,
        Output
    > {
        package let node: Node<Input, Failure>.ID

        package init(node: Node<Input, Failure>.ID) {
            self.node = node
        }
    }
}
