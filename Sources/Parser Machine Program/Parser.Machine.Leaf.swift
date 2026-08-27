public import Input
public import Machine
import Parser
public import Tagged

extension Parser.Machine {

    @inlinable
    public static func leaf<Input, Output, Failure, P>(
        _ parser: consuming P,
        in builder: inout Builder<Input, Failure>
    ) -> Expression<Input, Failure, Output>
    where
        P: Parser.Parser.`Protocol` & ~Copyable,
        P.Input == Input,
        P.Output == Output,
        P.Failure == Failure,
        Input: Input.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    {
        let node = Node<Input, Failure>.leaf(
            Leaf { (input: inout Input) throws(Failure) -> Value in
                Value.make(try parser.parse(&input))
            }
        )
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }

    @inlinable
    public static func leaf<Input, Output, Failure, P>(
        _ parser: consuming P,
        mapError: @escaping (P.Failure) -> Failure,
        in builder: inout Builder<Input, Failure>
    ) -> Expression<Input, Failure, Output>
    where
        P: Parser.Parser.`Protocol` & ~Copyable,
        P.Input == Input,
        P.Output == Output,
        Input: Input.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    {
        let node = Node<Input, Failure>.leaf(
            Leaf { (input: inout Input) throws(Failure) -> Value in
                do throws(P.Failure) {
                    return Value.make(try parser.parse(&input))
                } catch {
                    throw mapError(error)
                }
            }
        )
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }
}
