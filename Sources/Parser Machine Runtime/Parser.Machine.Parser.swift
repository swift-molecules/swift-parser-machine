public import Checkpoint
public import Cursor
public import Iterator
public import Machine
public import Parser_Machine_Program
import Parser

extension Machine.Parser {

    public struct Parser<
        Input: Cursor.`Protocol` & ~Copyable,
        Output,
        Failure: Swift.Error
    >: Parser::Parsing {
        public var body: Never {
            borrowing get {
                return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
            }
        }

        package let program: Program<Input, Failure>

        package let root: Node<Input, Failure>.ID

        package let depthFailure: ((Int) -> Failure)?

        package init(
            program: Program<Input, Failure>,
            root: Node<Input, Failure>.ID,
            depthFailure: ((Int) -> Failure)? = nil
        ) {
            self.program = program
            self.root = root
            self.depthFailure = depthFailure
        }

        public func parse(_ input: inout Input) throws(Failure) -> Output {
            try Machine::Machine.Parser.run(
                program: program,
                root: root,
                input: &input,
                as: Output.self,
                depthFailure: depthFailure
            )
        }
    }
}
