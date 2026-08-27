public import Input

extension Parser.Parse
where
    P.Input: Input.Input.`Protocol`,
    P.Failure: Swift.Error
{

    public func compiled(
        using witness: Parser.Machine.Compile.Witness<P>
    ) -> Parser.Machine.Compiled<P> {
        Parser.Machine.Compiled(source: parser, witness: witness)
    }

    public func prepared(
        using witness: Parser.Machine.Compile.Witness<P>
    ) -> Parser.Machine.Prepared<P> {
        Parser.Machine.Prepared(source: parser, witness: witness)
    }

    public func compiled() -> Parser.Machine.Compiled<P> {
        compiled(using: .leaf)
    }

    public func prepared() -> Parser.Machine.Prepared<P> {
        prepared(using: .leaf)
    }
}

extension Parser.Parse
where
    P: ~Copyable,
    P.Input: Input.Input.`Protocol`,
    P.Failure: Swift.Error
{

    public consuming func compiled(
        using witness: Parser.Machine.Compile.Witness<P>
    ) -> Parser.Machine.Compiled<P> {
        Parser.Machine.Compiled(source: parser, witness: witness)
    }

    public consuming func prepared(
        using witness: Parser.Machine.Compile.Witness<P>
    ) -> Parser.Machine.Prepared<P> {
        Parser.Machine.Prepared(source: parser, witness: witness)
    }

    public consuming func compiled() -> Parser.Machine.Compiled<P> {
        compiled(using: .leaf)
    }

    public consuming func prepared() -> Parser.Machine.Prepared<P> {
        prepared(using: .leaf)
    }
}
