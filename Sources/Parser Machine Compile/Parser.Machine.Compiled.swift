public import Checkpoint
public import Cursor
public import Iterator
public import Machine

extension Machine.Parser {

    public struct Compiled<
        P: Parser::Parsing<P.Input, P.Output, P.Failure> & ~Copyable
    >: Copyable
    where
        P.Input: Cursor.`Protocol`,
        P.Failure: Swift.Error
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
