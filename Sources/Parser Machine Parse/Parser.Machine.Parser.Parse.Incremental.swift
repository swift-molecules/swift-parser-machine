public import Machine

extension Machine.Parser.Parser.Parse where Input.Checkpoint: Hashable {

    public var incremental: Incremental {
        Incremental(parser: parser)
    }
}

extension Machine.Parser.Parser.Parse {

    public struct Incremental where Input.Checkpoint: Hashable {
        package let parser: Machine.Parser.Parser<Input, Output, Failure>

        package var memoization: Machine.Parser.Memoization.Table<Input.Checkpoint>

        public init(parser: Machine.Parser.Parser<Input, Output, Failure>) {
            self.parser = parser
            self.memoization = .init()
        }

        public init(parser: Machine.Parser.Parser<Input, Output, Failure>, capacity: Int) {
            self.parser = parser
            self.memoization = .init(capacity: capacity)
        }
    }
}

extension Machine.Parser.Parser.Parse.Incremental {

    public mutating func callAsFunction(_ input: inout Input) throws(Failure) -> Output {
        try Machine.Parser.run(
            program: parser.program,
            root: parser.root,
            input: &input,
            memoization: &memoization,
            as: Output.self,
            depthFailure: parser.depthFailure
        )
    }
}

extension Machine.Parser.Parser.Parse.Incremental where Input.Checkpoint: Comparable {

    public mutating func invalidate(_ edit: Machine.Parser.Memoization.Edit<Input.Checkpoint>) {
        memoization.invalidate(edit)
    }

    public mutating func invalidate(from position: Input.Checkpoint) {
        memoization.invalidate(from: position)
    }
}

extension Machine.Parser.Parser.Parse.Incremental {

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
