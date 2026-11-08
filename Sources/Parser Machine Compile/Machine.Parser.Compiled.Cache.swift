import Checkpoint
public import Cursor
import Iterator
public import Machine


extension Machine.Parser.Compiled where P: ~Copyable {
    @usableFromInline
    final class Cache {
        @usableFromInline
        var compiled: Result?

        @usableFromInline
        var source: P?

        @usableFromInline
        let witness: Machine.Parser.Compile.Witness<P>

        @usableFromInline
        init(source: consuming P, witness: Machine.Parser.Compile.Witness<P>) {
            self.compiled = nil
            self.source = consume source
            self.witness = witness
        }
    }
}
