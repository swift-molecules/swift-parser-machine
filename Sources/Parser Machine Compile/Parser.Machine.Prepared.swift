public import Checkpoint
public import Cursor
public import Iterator
public import Iterator_Protocol
public import Machine

extension Parser.Machine {

    public struct Prepared<P: Parser.Parser.`Protocol` & ~Copyable>
    where
        P.Input: Cursor.`Protocol`,
        P.Failure: Swift.Error
    {
        @usableFromInline
        let program: Program<P.Input, P.Failure>

        @usableFromInline
        let root: Node<P.Input, P.Failure>.ID

        @inlinable
        package init(
            program: Program<P.Input, P.Failure>,
            root: Node<P.Input, P.Failure>.ID
        ) {
            self.program = program
            self.root = root
        }

        public init(source: consuming P, witness: Compile.Witness<P>) {
            var builder = Builder<P.Input, P.Failure>()
            let expression = witness.compile(source, into: &builder)
            self.root = expression.node
            self.program = builder.build()
        }
    }
}

extension Parser.Machine.Prepared: Parser.Parser.`Protocol` where P: ~Copyable {

    public typealias Input = P.Input

    public typealias Output = P.Output

    public typealias Failure = P.Failure

    public func parse(_ input: inout Input) throws(Failure) -> Output {
        try Parser.Machine.run(program: program, root: root, input: &input, as: Output.self)
    }
}
