public import Checkpoint
public import Cursor
public import Iterator
public import Iterator_Protocol
public import Machine
import Parser

extension Parser.Machine {

    public struct Builder<
        Input: Cursor.`Protocol` & ~Copyable,
        Failure: Swift.Error
    >: ~Copyable {
        package var inner: Machine.Machine.Builder<Leaf<Input, Failure>, Failure, Mode>

        package init(maxDepth: Int? = nil) {
            self.inner = Machine.Machine.Builder(maxDepth: maxDepth)
        }

        @usableFromInline
        package mutating func allocate(_ node: Node<Input, Failure>) -> Node<Input, Failure>.ID {
            inner.allocate(node)
        }

        package var captures: Machine.Machine.Capture.Store<Mode> {
            get { inner.captures }
            _modify { yield &inner.captures }
        }

        package consuming func build() -> Program<Input, Failure> {
            inner.build()
        }
    }
}
