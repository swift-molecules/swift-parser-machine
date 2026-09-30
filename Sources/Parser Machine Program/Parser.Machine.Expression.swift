public import Checkpoint
public import Cursor
public import Iterator
public import Machine
import Parser

extension Machine.Parser {

    public struct Expression<
        Input: Cursor.`Protocol` & ~Copyable,
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
