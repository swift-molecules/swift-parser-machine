public import Input_Primitives
internal import Machine_Primitives
import Parser_Primitives
internal import Tagged_Primitives

extension Parser.Machine {

    public static func pure<Input, Output, Failure>(
        _ value: Output,
        in builder: inout Builder<Input, Failure>
    ) -> Expression<Input, Failure, Output>
    where
        Input: Input_Primitives.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    {
        let node = Node<Input, Failure>.pure(Value.make(value))
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }
}

extension Parser.Machine.Expression {

    public func map<T>(
        _ transform: @escaping (Output) -> T,
        in builder: inout Parser.Machine.Builder<Input, Failure>
    ) -> Parser.Machine.Expression<Input, Failure, T> {
        let captureID = builder.captures.insert(transform)
        let node = Parser.Machine.Node<Input, Failure>.map(
            child: self.node,
            transform: Parser.Machine.Transform.Erased(capture: captureID)
        )
        let nodeID = builder.allocate(node)
        return Parser.Machine.Expression(node: nodeID)
    }
}

extension Parser.Machine.Expression {

    public func tryMap<T>(
        _ transform: @escaping (Output) throws(Failure) -> T,
        in builder: inout Parser.Machine.Builder<Input, Failure>
    ) -> Parser.Machine.Expression<Input, Failure, T> {
        Parser.Machine.tryMap(self, transform, in: &builder)
    }
}

extension Parser.Machine {

    public static func tryMap<Input, Output, Failure, NewOutput>(
        _ expr: Expression<Input, Failure, Output>,
        _ transform: @escaping (Output) throws(Failure) -> NewOutput,
        in builder: inout Builder<Input, Failure>
    ) -> Expression<Input, Failure, NewOutput>
    where
        Input: Input_Primitives.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    {
        let captureID = builder.captures.insert(transform)
        let node = Node<Input, Failure>.tryMap(
            child: expr.node,
            transform: Transform.Throwing(capture: captureID)
        )
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }
}

extension Parser.Machine.Expression {

    public func flatMap<T>(
        _ next: @escaping (Output) -> Parser.Machine.Expression<Input, Failure, T>,
        in builder: inout Parser.Machine.Builder<Input, Failure>
    ) -> Parser.Machine.Expression<Input, Failure, T> {
        typealias NodeID = Parser.Machine.Node<Input, Failure>.ID
        let nextFn: (Output) -> NodeID = { output in
            next(output).node
        }
        let captureID = builder.captures.insert(nextFn)
        let node = Parser.Machine.Node<Input, Failure>.flatMap(
            child: self.node,
            next: Parser.Machine.Next.Erased(capture: captureID)
        )
        let nodeID = builder.allocate(node)
        return Parser.Machine.Expression(node: nodeID)
    }
}

extension Parser.Machine {

    public static func sequence<Input, Failure, A, B, C>(
        _ a: Expression<Input, Failure, A>,
        _ b: Expression<Input, Failure, B>,
        combine: @escaping (A, B) -> C,
        in builder: inout Builder<Input, Failure>
    ) -> Expression<Input, Failure, C>
    where
        Input: Input_Primitives.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    {
        let captureID = builder.captures.insert(combine)
        let node = Node<Input, Failure>.sequence(
            a: a.node,
            b: b.node,
            combine: Combine.Erased(capture: captureID)
        )
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }
}

extension Parser.Machine {

    public static func oneOf<Input, Failure, Output>(
        _ alternatives: [Expression<Input, Failure, Output>],
        in builder: inout Builder<Input, Failure>
    ) -> Expression<Input, Failure, Output>
    where
        Input: Input_Primitives.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    {
        let nodeIDs = alternatives.map { $0.node }
        let node = Node<Input, Failure>.oneOf(nodeIDs)
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }
}

extension Parser.Machine {

    public static func many<Input, Failure, T>(
        _ expr: Expression<Input, Failure, T>,
        in builder: inout Builder<Input, Failure>
    ) -> Expression<Input, Failure, [T]>
    where
        Input: Input_Primitives.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    {
        let node = Node<Input, Failure>.many(
            child: expr.node,
            finalize: Finalize.Array(elementType: T.self, store: &builder.captures)
        )
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }
}

extension Parser.Machine {

    public static func optional<Input, Failure, T>(
        _ expr: Expression<Input, Failure, T>,
        in builder: inout Builder<Input, Failure>
    ) -> Expression<Input, Failure, T?>
    where
        Input: Input_Primitives.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    {
        let wrapSome: (T) -> T? = { Swift.Optional.some($0) }
        let captureID = builder.captures.insert(wrapSome)
        let node = Node<Input, Failure>.optional(
            child: expr.node,
            wrapSome: Transform.Erased(capture: captureID),
            noneValue: Value.make(T?.none)
        )
        let nodeID = builder.allocate(node)
        return Expression(node: nodeID)
    }
}

extension Parser.Machine.Reference {

    public func expression(
        in builder: inout Parser.Machine.Builder<Input, Failure>
    ) -> Parser.Machine.Expression<Input, Failure, Output> {
        let node = Parser.Machine.Node<Input, Failure>.ref(self.node)
        let nodeID = builder.allocate(node)
        return Parser.Machine.Expression(node: nodeID)
    }
}
