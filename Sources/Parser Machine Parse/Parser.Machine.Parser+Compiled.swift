public import Machine
public import Checkpoint
public import Cursor
public import Iterator
public import Parser

extension Parser::Parsing
where
    Self: ~Copyable,
    Input: Cursor.`Protocol`
{

    public consuming func compiled(
        using witness: Machine.Parser.Compile.Witness<Self>
    ) -> Machine.Parser.Compiled<Self> {
        Machine.Parser.Compiled(source: self, witness: witness)
    }

    public consuming func prepared(
        using witness: Machine.Parser.Compile.Witness<Self>
    ) -> Machine.Parser.Prepared<Self> {
        Machine.Parser.Prepared(source: self, witness: witness)
    }

    public consuming func compiled() -> Machine.Parser.Compiled<Self> {
        compiled(using: .leaf)
    }

    public consuming func prepared() -> Machine.Parser.Prepared<Self> {
        prepared(using: .leaf)
    }
}
