public import Input
internal import Machine
import Parser
internal import Tagged

extension Parser.Machine {

    public static func recursive<Input, Output, Failure>(
        maxDepth: Int? = nil,
        onDepthExceeded: ((Int) -> Failure)? = nil,
        _ build: (
            inout Builder<Input, Failure>,
            Reference<Input, Failure, Output>
        ) -> Expression<Input, Failure, Output>
    ) -> Parser<Input, Output, Failure>
    where
        Input: Input.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    {
        var builder = Builder<Input, Failure>(maxDepth: maxDepth)

        let holeID = builder.allocate(.hole)
        let ref = Reference<Input, Failure, Output>(node: holeID)

        let root = build(&builder, ref)

        builder.inner[holeID] = .ref(root.node)

        return Parser(program: builder.build(), root: root.node, depthFailure: onDepthExceeded)
    }

    public static func build<Input, Output, Failure>(
        _ build: (inout Builder<Input, Failure>) -> Expression<Input, Failure, Output>
    ) -> Parser<Input, Output, Failure>
    where
        Input: Input.Input.`Protocol` & ~Copyable,
        Failure: Swift.Error
    {
        var builder = Builder<Input, Failure>()
        let root = build(&builder)
        return Parser(program: builder.build(), root: root.node)
    }
}
