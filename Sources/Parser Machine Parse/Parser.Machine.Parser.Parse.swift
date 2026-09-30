public import Machine

extension Machine.Parser.Parser {

    public struct Parse {
        package let parser: Machine.Parser.Parser<Input, Output, Failure>

        package init(parser: Machine.Parser.Parser<Input, Output, Failure>) {
            self.parser = parser
        }
    }

    public var parse: Parse {
        Parse(parser: self)
    }
}

extension Machine.Parser.Parser.Parse {

    public func callAsFunction(_ input: inout Input) throws(Failure) -> Output {
        try Machine.Parser.run(
            program: parser.program,
            root: parser.root,
            input: &input,
            as: Output.self,
            depthFailure: parser.depthFailure
        )
    }
}
