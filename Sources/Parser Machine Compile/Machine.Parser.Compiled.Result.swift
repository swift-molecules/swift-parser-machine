import Checkpoint
public import Cursor
import Iterator
public import Machine


extension Machine.Parser.Compiled where P: ~Copyable {
    @usableFromInline
    struct Result {
        @usableFromInline
        let program: Machine.Parser.Program<P.Input, P.Failure>

        @usableFromInline
        let root: Machine.Parser.Node<P.Input, P.Failure>.ID

        @usableFromInline
        init(
            program: Machine.Parser.Program<P.Input, P.Failure>,
            root: Machine.Parser.Node<P.Input, P.Failure>.ID
        ) {
            self.program = program
            self.root = root
        }
    }
}
