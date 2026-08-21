public import Input_Primitives
public import Machine_Primitives
import Parser_Primitives

extension Parser.Machine {

    public struct Expression<
        Input: Input_Primitives.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error,
        Output
    > {
        package let node: Node<Input, Failure>.ID

        @usableFromInline
        package init(node: Node<Input, Failure>.ID) {
            self.node = node
        }
    }
}
