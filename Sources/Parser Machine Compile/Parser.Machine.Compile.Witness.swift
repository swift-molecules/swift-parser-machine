import Checkpoint
import Cursor
import Iterator
public import Machine

extension Machine.Parser {

    public enum Compile {}
}

extension Machine.Parser.Compile {
}

extension Machine.Parser.Compile.Witness where P: ~Copyable {

    @inlinable
    public static var leaf: Self {
        Self { parser, builder in
            Machine.Parser.leaf(parser, in: &builder)
        }
    }
}
