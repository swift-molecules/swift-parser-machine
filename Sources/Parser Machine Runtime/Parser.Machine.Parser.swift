public import Input
public import Machine
public import Parser_Machine_Program
import Parser

extension Parser.Machine {

    public struct Parser<
        Input: Input.Input.`Protocol` & ~Copyable,
        Output,
        Failure: Swift.Error
    >: Parser.Parser.`Protocol` {
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
            try Parser.Parser.Machine.run(
                program: program,
                root: root,
                input: &input,
                as: Output.self,
                depthFailure: depthFailure
            )
        }
    }
}
