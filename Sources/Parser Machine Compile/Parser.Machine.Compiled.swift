public import Input
public import Machine

extension Parser.Machine {

    public struct Compiled<
        P: Parser.Parser.`Protocol`<P.Input, P.Output, P.Failure> & ~Copyable
    >: Copyable
    where
        P.Input: Input.Input.`Protocol`<P.Input.Element>,
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

extension Parser.Machine.Compiled where P: ~Copyable {

    @usableFromInline
    struct Result {
        @usableFromInline
        let program: Parser.Machine.Program<P.Input, P.Failure>

        @usableFromInline
        let root: Parser.Machine.Node<P.Input, P.Failure>.ID

        @usableFromInline
        init(
            program: Parser.Machine.Program<P.Input, P.Failure>,
            root: Parser.Machine.Node<P.Input, P.Failure>.ID
        ) {
            self.program = program
            self.root = root
        }
    }
}

extension Parser.Machine.Compiled where P: ~Copyable {

    @usableFromInline
    final class Cache {
        @usableFromInline
        var compiled: Result?

        @usableFromInline
        var source: P?

        @usableFromInline
        let witness: Parser.Machine.Compile.Witness<P>

        @usableFromInline
        init(source: consuming P, witness: Parser.Machine.Compile.Witness<P>) {
            self.compiled = nil
            self.source = consume source
            self.witness = witness
        }
    }
}

extension Parser.Machine.Compiled.Cache where P: ~Copyable {
    @usableFromInline
    func getOrCompile() -> Parser.Machine.Compiled<P>.Result {
        if let existing = compiled {
            return existing
        }
        guard let parser = source.take() else {

            fatalError("Parser.Machine.Compiled.Cache: source consumed but result missing")
        }
        var builder = Parser.Machine.Builder<P.Input, P.Failure>()
        let expression = witness.compile(parser, into: &builder)
        let result = Parser.Machine.Compiled<P>.Result(
            program: builder.build(),
            root: expression.node
        )
        compiled = result
        return result
    }
}

extension Parser.Machine.Compiled: Parser.Parser.`Protocol` where P: ~Copyable {

    public typealias Input = P.Input

    public typealias Output = P.Output

    public typealias Failure = P.Failure

    public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
        let result = cache.getOrCompile()
        return try Parser.Machine.run(
            program: result.program,
            root: result.root,
            input: &input,
            as: Output.self
        )
    }
}
