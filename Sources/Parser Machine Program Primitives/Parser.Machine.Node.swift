public import Input_Primitives
public import Machine_Primitives
import Parser_Primitives
internal import Tagged_Primitives

extension Parser.Machine {

    public typealias Node<
        Input: Input_Primitives.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    > =
        Machine_Primitives.Machine.Node<Leaf<Input, Failure>, Failure, Mode>

    public struct Leaf<Input: Input_Primitives.Input.`Protocol` & ~Copyable, Failure: Swift.Error> {
        @usableFromInline
        package let run: (inout Input) throws(Failure) -> Value

        @usableFromInline
        package init(_ run: @escaping (inout Input) throws(Failure) -> Value) {
            self.run = run
        }
    }
}
