import Checkpoint
public import Cursor
import Iterator
public import Machine
import Parser
internal import Tagged

extension Machine.Parser {

    public static func recursive<Input, Output, Failure>(
        _ build: (
            inout Builder<Input, Failure>,
            Reference<Input, Failure, Output>
        ) -> Expression<Input, Failure, Output>
    ) -> Parser<Input, Output, Failure>
    where
        Input: Cursor.`Protocol` & ~Copyable,
        Failure: Swift::Error
    {
        recursive(limit: nil, depthFailure: nil, build: build)
    }

    public static func recursive<Input, Output, Failure>(
        maxDepth: Int,
        onDepthExceeded: @escaping (Int) -> Failure,
        _ build: (
            inout Builder<Input, Failure>,
            Reference<Input, Failure, Output>
        ) -> Expression<Input, Failure, Output>
    ) -> Parser<Input, Output, Failure>
    where
        Input: Cursor.`Protocol` & ~Copyable,
        Failure: Swift::Error
    {
        recursive(limit: maxDepth, depthFailure: onDepthExceeded, build: build)
    }

    private static func recursive<Input, Output, Failure>(
        limit: Int?,
        depthFailure: ((Int) -> Failure)?,
        build: (
            inout Builder<Input, Failure>,
            Reference<Input, Failure, Output>
        ) -> Expression<Input, Failure, Output>
    ) -> Parser<Input, Output, Failure>
    where
        Input: Cursor.`Protocol` & ~Copyable,
        Failure: Swift::Error
    {
        var builder = Builder<Input, Failure>(maxDepth: limit)

        let holeID = builder.allocate(.hole)
        let ref = Reference<Input, Failure, Output>(node: holeID)

        let root = build(&builder, ref)

        builder.inner[holeID] = .ref(root.node)

        return Parser(program: builder.build(), root: root.node, depthFailure: depthFailure)
    }

    public static func build<Input, Output, Failure>(
        _ build: (inout Builder<Input, Failure>) -> Expression<Input, Failure, Output>
    ) -> Parser<Input, Output, Failure>
    where
        Input: Cursor.`Protocol` & ~Copyable,
        Failure: Swift::Error
    {
        var builder = Builder<Input, Failure>()
        let root = build(&builder)
        return Parser(program: builder.build(), root: root.node)
    }
}
