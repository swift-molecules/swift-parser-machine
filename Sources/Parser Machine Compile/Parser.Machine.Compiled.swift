import Checkpoint
public import Cursor
import Iterator
public import Machine

extension Machine.Parser {

    public struct Compiled<
        P: Parser::Parsing<P.Input, P.Output, P.Failure> & ~Copyable
    >: Copyable
    where
        P.Input: Cursor.`Protocol`,
        P.Failure: Swift::Error
    {

        @usableFromInline
        let cache: Cache

        @inlinable
        public init(source: consuming P, witness: Compile.Witness<P>) {
            self.cache = Cache(source: source, witness: witness)
        }

        @inlinable
        public borrowing func prepared() -> Prepared<P> {
            let result = cache.getOrCompile()
            return Prepared(program: result.program, root: result.root)
        }
    }
}

extension Machine.Parser.Compiled where P: ~Copyable {
}

extension Machine.Parser.Compiled where P: ~Copyable {
}

extension Machine.Parser.Compiled.Cache where P: ~Copyable {
    @usableFromInline
    func getOrCompile() -> Machine.Parser.Compiled<P>.Result {
        if let existing = compiled {
            return existing
        }
        guard let parser = source.take() else {

            fatalError("Machine.Parser.Compiled.Cache: source consumed but result missing")
        }
        var builder = Machine.Parser.Builder<P.Input, P.Failure>()
        let expression = witness.compile(parser, into: &builder)
        let result = Machine.Parser.Compiled<P>.Result(
            program: builder.build(),
            root: expression.node
        )
        compiled = result
        return result
    }
}

extension Machine.Parser.Compiled: Parser::Parsing where P: ~Copyable {

    public typealias Input = P.Input

    public typealias Output = P.Output

    public typealias Failure = P.Failure

    public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
        let result = cache.getOrCompile()
        return try Machine.Parser.run(
            program: result.program,
            root: result.root,
            input: &input,
            as: Output.self
        )
    }
}
