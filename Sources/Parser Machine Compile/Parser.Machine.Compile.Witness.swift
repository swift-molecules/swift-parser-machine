public import Machine
public import Checkpoint
public import Cursor
public import Iterator

extension Machine.Parser {

    public enum Compile {}
}

extension Machine.Parser.Compile {

    public struct Witness<P: Parser::Parsing & ~Copyable>
    where
        P.Input: Cursor.`Protocol`,
        P.Failure: Swift.Error
    {
        @usableFromInline
        let _compile:
            (
                consuming P,
                inout Machine.Parser.Builder<P.Input, P.Failure>
            ) -> Machine.Parser.Expression<P.Input, P.Failure, P.Output>

        @inlinable
        public init(
            compile:
                @escaping (
                    consuming P,
                    inout Machine.Parser.Builder<P.Input, P.Failure>
                ) -> Machine.Parser.Expression<P.Input, P.Failure, P.Output>
        ) {
            self._compile = compile
        }

        @inlinable
        public func compile(
            _ parser: consuming P,
            into builder: inout Machine.Parser.Builder<P.Input, P.Failure>
        ) -> Machine.Parser.Expression<P.Input, P.Failure, P.Output> {
            _compile(parser, &builder)
        }
    }
}

extension Machine.Parser.Compile.Witness where P: ~Copyable {

    @inlinable
    public static var leaf: Self {
        Self { parser, builder in
            Machine.Parser.leaf(parser, in: &builder)
        }
    }
}
