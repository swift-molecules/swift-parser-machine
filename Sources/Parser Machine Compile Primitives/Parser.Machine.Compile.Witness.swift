public import Input_Primitives

extension Parser.Machine {

    public enum Compile {}
}

extension Parser.Machine.Compile {

    public struct Witness<P: Parser_Primitives.Parser.`Protocol` & ~Copyable>
    where
        P.Input: Input_Primitives.Input.`Protocol`,
        P.Failure: Swift.Error
    {
        @usableFromInline
        let _compile:
            (
                consuming P,
                inout Parser.Machine.Builder<P.Input, P.Failure>
            ) -> Parser.Machine.Expression<P.Input, P.Failure, P.Output>

        @inlinable
        public init(
            compile:
                @escaping (
                    consuming P,
                    inout Parser.Machine.Builder<P.Input, P.Failure>
                ) -> Parser.Machine.Expression<P.Input, P.Failure, P.Output>
        ) {
            self._compile = compile
        }

        @inlinable
        public func compile(
            _ parser: consuming P,
            into builder: inout Parser.Machine.Builder<P.Input, P.Failure>
        ) -> Parser.Machine.Expression<P.Input, P.Failure, P.Output> {
            _compile(parser, &builder)
        }
    }
}

extension Parser.Machine.Compile.Witness where P: ~Copyable {

    @inlinable
    public static var leaf: Self {
        Self { parser, builder in
            Parser.Machine.leaf(parser, in: &builder)
        }
    }
}
