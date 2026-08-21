internal import Machine_Primitives

extension Parser.Machine.Parser.Parse where Input.Checkpoint: Hashable {

    public var incremental: Incremental {
        Incremental(parser: parser)
    }
}

extension Parser.Machine.Parser.Parse {

    public struct Incremental where Input.Checkpoint: Hashable {
        package let parser: Parser.Machine.Parser<Input, Output, Failure>

        package var memoization: Parser.Machine.Memoization.Table<Input.Checkpoint>

        public init(parser: Parser.Machine.Parser<Input, Output, Failure>) {
            self.parser = parser
            self.memoization = .init()
        }

        public init(parser: Parser.Machine.Parser<Input, Output, Failure>, capacity: Int) {
            self.parser = parser
            self.memoization = .init(capacity: capacity)
        }
    }
}

extension Parser.Machine.Parser.Parse.Incremental {

    public mutating func callAsFunction(_ input: inout Input) throws(Failure) -> Output {
        try Parser.Machine.run(
            program: parser.program,
            root: parser.root,
            input: &input,
            memoization: &memoization,
            as: Output.self,
            depthFailure: parser.depthFailure
        )
    }
}

extension Parser.Machine.Parser.Parse.Incremental where Input.Checkpoint: Comparable {

    public mutating func invalidate(_ edit: Parser.Machine.Memoization.Edit<Input.Checkpoint>) {
        memoization.invalidate(edit)
    }

    public mutating func invalidate(from position: Input.Checkpoint) {
        memoization.invalidate(from: position)
    }
}

extension Parser.Machine.Parser.Parse.Incremental {

    public var count: Int {
        memoization.count
    }

    public var isEmpty: Bool {
        memoization.isEmpty
    }

    public mutating func clear() {
        memoization.clear()
    }
}
