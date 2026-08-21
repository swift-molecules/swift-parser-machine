internal import Machine_Primitives

extension Parser.Machine.Parser {

    public struct Parse {
        package let parser: Parser.Machine.Parser<Input, Output, Failure>

        package init(parser: Parser.Machine.Parser<Input, Output, Failure>) {
            self.parser = parser
        }
    }

    public var parse: Parse {
        Parse(parser: self)
    }
}

extension Parser.Machine.Parser.Parse {

    public func callAsFunction(_ input: inout Input) throws(Failure) -> Output {
        try Parser.Machine.run(
            program: parser.program,
            root: parser.root,
            input: &input,
            as: Output.self,
            depthFailure: parser.depthFailure
        )
    }
}
