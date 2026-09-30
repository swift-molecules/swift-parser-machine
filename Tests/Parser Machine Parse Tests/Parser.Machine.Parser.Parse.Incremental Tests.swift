import Collection_Parser_Test_Support
import Machine
import Parser_Machine_Combinator
import Parser_Machine_Memoization
import Parser_Machine_Parse
import Parser_Test_Support
import Testing

private struct OpenParen: Parsing, Sendable {}

extension OpenParen {
    enum Error: Swift.Error, Sendable { case expected }
    func parse(_ input: inout Input) throws(Error) {
        guard input.first == UInt8(ascii: "(") else { throw .expected }

        input = input[input.index(after: input.startIndex)..<input.endIndex]
    }
}

private struct CloseParen: Parsing, Sendable {}

extension CloseParen {
    enum Error: Swift.Error, Sendable { case expected }
    func parse(_ input: inout Input) throws(Error) {
        guard input.first == UInt8(ascii: ")") else { throw .expected }

        input = input[input.index(after: input.startIndex)..<input.endIndex]
    }
}

private enum TestError: Swift.Error, Sendable {
    case openParen
    case closeParen
}

@Suite
struct `Machine.Parser.Parser.Parse.Incremental Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Machine.Parser.Parser.Parse.Incremental Tests`.Unit {
    @Test
    func `incremental context parses correctly`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8, MatchByte.Error> =
            Machine.Parser.build { builder in
                Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
            }

        var ctx = parser.parse.incremental
        var input = Input([65, 66, 67])
        let result = try ctx(&input)
        #expect(result == 65)
    }

    @Test
    func `memoization table populates during parsing`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8, MatchByte.Error> =
            Machine.Parser.build { builder in
                Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
            }

        var ctx = parser.parse.incremental
        #expect(ctx.isEmpty)

        var input = Input([65])
        _ = try ctx(&input)
        #expect(ctx.count > 0)
    }

    @Test
    func `clear removes all cached entries`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8, MatchByte.Error> =
            Machine.Parser.build { builder in
                Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
            }

        var ctx = parser.parse.incremental
        var input = Input([65])
        _ = try ctx(&input)
        #expect(ctx.count > 0)

        ctx.clear()
        #expect(ctx.isEmpty)
    }

    @Test
    func `re-parsing produces same result`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8, MatchByte.Error> =
            Machine.Parser.build { builder in
                Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
            }

        var ctx = parser.parse.incremental

        var input1 = Input([65])
        let result1 = try ctx(&input1)

        var input2 = Input([65])
        let result2 = try ctx(&input2)

        #expect(result1 == result2)
    }
}

extension `Machine.Parser.Parser.Parse.Incremental Tests`.`Edge Case` {
    @Test
    func `invalidate from position clears entries at or after`() throws {
        let parser: Machine.Parser.Parser<Input, (UInt8, UInt8), MatchByte.Error> =
            Machine.Parser.build { builder in
                let first = Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
                let second = Machine.Parser.leaf(MatchByte(expected: 66), in: &builder)
                return Machine.Parser.sequence(first, second, combine: { ($0, $1) }, in: &builder)
            }

        var ctx = parser.parse.incremental
        var input = Input([65, 66])
        _ = try ctx(&input)

        let countBefore = ctx.count
        #expect(countBefore > 0)

        ctx.invalidate(from: 1)
        #expect(ctx.count < countBefore)
    }

    @Test
    func `invalidate with edit descriptor removes affected entries`() throws {
        let parser: Machine.Parser.Parser<Input, (UInt8, UInt8, UInt8), MatchByte.Error> =
            Machine.Parser.build { builder in
                let a = Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
                let b = Machine.Parser.leaf(MatchByte(expected: 66), in: &builder)
                let c = Machine.Parser.leaf(MatchByte(expected: 67), in: &builder)
                let ab = Machine.Parser.sequence(a, b, combine: { ($0, $1) }, in: &builder)
                return Machine.Parser.sequence(ab, c, combine: { ($0.0, $0.1, $1) }, in: &builder)
            }

        var ctx = parser.parse.incremental
        var input = Input([65, 66, 67])
        _ = try ctx(&input)

        let countBefore = ctx.count

        ctx.invalidate(.init(start: 1, oldEnd: 1, newEnd: 2))
        #expect(ctx.count < countBefore)
    }

    @Test
    func `re-parsing previously-failed input throws the same typed failure`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8, MatchByte.Error> =
            Machine.Parser.build { builder in
                Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
            }

        var ctx = parser.parse.incremental

        var input1 = Input([90])
        #expect(throws: MatchByte.Error.self) {
            _ = try ctx(&input1)
        }

        var input2 = Input([90])
        #expect(throws: MatchByte.Error.self) {
            _ = try ctx(&input2)
        }
    }

    @Test
    func `invalidate from position drops success entries whose span crosses the cutoff`() throws {
        let parser: Machine.Parser.Parser<Input, [UInt8], ByteParser.Error> =
            Machine.Parser.build { builder in
                let byte = Machine.Parser.leaf(ByteParser(), in: &builder)
                return Machine.Parser.many(byte, in: &builder)
            }

        var ctx = parser.parse.incremental
        var input1 = Input([65, 66, 67, 68])
        let result1 = try ctx(&input1)
        #expect(result1 == [65, 66, 67, 68])

        ctx.invalidate(from: 2)

        var input2 = Input([65, 66, 99, 100])
        let result2 = try ctx(&input2)

        #expect(result2 == [65, 66, 99, 100])
    }

    @Test
    func `re-parse after insert edit matches a fresh parse of the edited content`() throws {
        let parser: Machine.Parser.Parser<Input, [UInt8], ByteParser.Error> =
            Machine.Parser.build { builder in
                let byte = Machine.Parser.leaf(ByteParser(), in: &builder)
                return Machine.Parser.many(byte, in: &builder)
            }

        var ctx = parser.parse.incremental
        var original = Input([65, 66, 67, 68, 69])
        _ = try ctx(&original)

        ctx.invalidate(.init(start: 0, oldEnd: 0, newEnd: 1))
        var edited = Input([88, 65, 66, 67, 68, 69])
        let incrementalResult = try ctx(&edited)

        var fresh = Input([88, 65, 66, 67, 68, 69])
        let freshResult = try parser.parse(&fresh)

        #expect(incrementalResult == freshResult)
    }

    @Test
    func `re-parse after delete edit matches a fresh parse of the edited content`() throws {
        let parser: Machine.Parser.Parser<Input, [UInt8], ByteParser.Error> =
            Machine.Parser.build { builder in
                let byte = Machine.Parser.leaf(ByteParser(), in: &builder)
                return Machine.Parser.many(byte, in: &builder)
            }

        var ctx = parser.parse.incremental
        var original = Input([65, 66, 67, 68, 69])
        _ = try ctx(&original)

        ctx.invalidate(.delete(from: 1, to: 2))
        var edited = Input([65, 67, 68, 69])
        let incrementalResult = try ctx(&edited)

        var fresh = Input([65, 67, 68, 69])
        let freshResult = try parser.parse(&fresh)

        #expect(incrementalResult == freshResult)
    }

    @Test
    func `re-parse after replace edit matches a fresh parse of the edited content`() throws {
        let parser: Machine.Parser.Parser<Input, [UInt8], ByteParser.Error> =
            Machine.Parser.build { builder in
                let byte = Machine.Parser.leaf(ByteParser(), in: &builder)
                return Machine.Parser.many(byte, in: &builder)
            }

        var ctx = parser.parse.incremental
        var original = Input([65, 66, 67, 68, 69])
        _ = try ctx(&original)

        ctx.invalidate(.init(start: 1, oldEnd: 3, newEnd: 2))
        var edited = Input([65, 90, 68, 69])
        let incrementalResult = try ctx(&edited)

        var fresh = Input([65, 90, 68, 69])
        let freshResult = try parser.parse(&fresh)

        #expect(incrementalResult == freshResult)
    }

    @Test
    func `many under memoization terminates when child succeeds without consuming input`() throws {
        let parser: Machine.Parser.Parser<Input, [Int], MatchByte.Error> =
            Machine.Parser.build { builder in
                let p = Machine.Parser.pure(7, in: &builder)
                return Machine.Parser.many(p, in: &builder)
            }

        var ctx = parser.parse.incremental
        var input = Input([65, 66, 67])
        let result = try ctx(&input)
        #expect(result == [7])
    }
}

extension `Machine.Parser.Parser.Parse.Incremental Tests`.Integration {
    @Test
    func `oneOf with memoization caches failed alternatives`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8, MatchByte.Error> =
            Machine.Parser.build { builder in
                let a = Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
                let b = Machine.Parser.leaf(MatchByte(expected: 66), in: &builder)
                let c = Machine.Parser.leaf(MatchByte(expected: 67), in: &builder)
                return Machine.Parser.oneOf([a, b, c], in: &builder)
            }

        var ctx = parser.parse.incremental

        var input = Input([67])
        let result = try ctx(&input)

        #expect(result == 67)
        #expect(ctx.count >= 3)
    }

    @Test
    func `recursive grammar with memoization`() throws {
        let parser: Machine.Parser.Parser<Input, Int, TestError> =
            Machine.Parser.recursive(maxDepth: 100) { builder, selfRef in
                let empty = Machine.Parser.pure(0, in: &builder)
                let open = Machine.Parser.leaf(
                    OpenParen(),
                    mapError: { _ in TestError.openParen },
                    in: &builder
                )
                let close = Machine.Parser.leaf(
                    CloseParen(),
                    mapError: { _ in TestError.closeParen },
                    in: &builder
                )
                let inner = selfRef.expression(in: &builder)

                let recursive = Machine.Parser.sequence(
                    open,
                    inner,
                    combine: { (_: Void, depth: Int) in depth },
                    in: &builder
                )
                let withClose = Machine.Parser.sequence(
                    recursive,
                    close,
                    combine: { (depth: Int, _: Void) in depth + 1 },
                    in: &builder
                )

                return Machine.Parser.oneOf([withClose, empty], in: &builder)
            }

        var ctx = parser.parse.incremental

        var input = makeInput("((()))")
        let depth = try ctx(&input)

        #expect(depth == 3)
        #expect(ctx.count > 0)
    }

    @Test
    func `fails then edit invalidates cached failure then re-parse succeeds`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8, MatchByte.Error> =
            Machine.Parser.build { builder in
                Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
            }

        var ctx = parser.parse.incremental

        var input1 = Input([90])
        #expect(throws: MatchByte.Error.self) {
            _ = try ctx(&input1)
        }

        ctx.invalidate(.init(start: 0, oldEnd: 1, newEnd: 1))
        var input2 = Input([65])
        let result = try ctx(&input2)
        #expect(result == 65)
    }

    @Test
    func `depth-exceeded ref failure is never cached as a foreign-typed entry`() throws {

        var refNodeID: Machine.Parser.Node<Input, TestError>.ID!
        let parser: Machine.Parser.Parser<Input, Int, TestError> =
            Machine.Parser.recursive(maxDepth: 1) { builder, selfRef in
                let empty = Machine.Parser.pure(0, in: &builder)
                let open = Machine.Parser.leaf(
                    OpenParen(),
                    mapError: { _ in TestError.openParen },
                    in: &builder
                )
                let close = Machine.Parser.leaf(
                    CloseParen(),
                    mapError: { _ in TestError.closeParen },
                    in: &builder
                )
                let inner = selfRef.expression(in: &builder)
                refNodeID = inner.node

                let recursive = Machine.Parser.sequence(
                    open,
                    inner,
                    combine: { (_: Void, depth: Int) in depth },
                    in: &builder
                )
                let withClose = Machine.Parser.sequence(
                    recursive,
                    close,
                    combine: { (depth: Int, _: Void) in depth + 1 },
                    in: &builder
                )

                return Machine.Parser.oneOf([withClose, empty], in: &builder)
            }

        var ctx = parser.parse.incremental
        var input = makeInput("((")

        let result = try ctx(&input)
        #expect(result == 0)

        for position: Input.Checkpoint in [0, 1, 2, 3] {
            let key = Machine.Parser.Memoization.Key<
                Input.Checkpoint
            >(position: position, node: refNodeID.underlying)
            switch ctx.memoization.lookup(key) {
            case .none:
                break

            case .success:
                Issue.record(
                    "expected no success entry for a depth-exceeding node at \(position)"
                )

            case .failure(let storedError):
                #expect(
                    storedError is TestError,
                    "cached failure at position \(position) is not TestError"
                )
            }
        }
    }
}
