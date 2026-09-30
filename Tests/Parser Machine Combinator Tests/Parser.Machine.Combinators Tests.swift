import Collection_Parser_Test_Support
import Machine
import Parser_Machine_Combinator
import Parser_Test_Support
import Testing

extension Machine.Parser {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

extension Machine.Parser.Test.Unit {
    @Test
    func `pure always succeeds with given value`() throws {
        let parser: Machine.Parser.Parser<Input, Int, ByteParser.Error> =
            Machine.Parser.build { builder in
                Machine.Parser.pure(42, in: &builder)
            }

        var input = Input([1, 2, 3])
        let result = try parser.parse(&input)
        #expect(result == 42)
        #expect(input.remainingBytes() == [1, 2, 3])
    }

    @Test
    func `leaf wraps parser as machine node`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8, ByteParser.Error> =
            Machine.Parser.build { builder in
                Machine.Parser.leaf(ByteParser(), in: &builder)
            }

        var input = Input([65, 66, 67])
        let result = try parser.parse(&input)
        #expect(result == 65)
        #expect(input.remainingBytes() == [66, 67])
    }

    @Test
    func `map transforms output`() throws {
        let parser: Machine.Parser.Parser<Input, Int, ByteParser.Error> =
            Machine.Parser.build { builder in
                let byte = Machine.Parser.leaf(ByteParser(), in: &builder)
                return byte.map({ Int($0) * 2 }, in: &builder)
            }

        var input = Input([10])
        let result = try parser.parse(&input)
        #expect(result == 20)
    }

    @Test
    func `sequence combines two parsers`() throws {
        let parser: Machine.Parser.Parser<Input, (UInt8, UInt8), ByteParser.Error> =
            Machine.Parser.build { builder in
                let first = Machine.Parser.leaf(ByteParser(), in: &builder)
                let second = Machine.Parser.leaf(ByteParser(), in: &builder)
                return Machine.Parser.sequence(first, second, combine: { ($0, $1) }, in: &builder)
            }

        var input = Input([1, 2, 3])
        let result = try parser.parse(&input)
        #expect(result.0 == 1)
        #expect(result.1 == 2)
        #expect(input.remainingBytes() == [3])
    }

    @Test
    func `oneOf selects first matching alternative`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8, MatchByte.Error> =
            Machine.Parser.build { builder in
                let a = Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
                    .map({ $0 }, in: &builder)
                let b = Machine.Parser.leaf(MatchByte(expected: 66), in: &builder)
                    .map({ $0 }, in: &builder)
                return Machine.Parser.oneOf([a, b], in: &builder)
            }

        var input = Input([65])
        let result = try parser.parse(&input)
        #expect(result == 65)
    }

    @Test
    func `oneOf falls through to second alternative`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8, MatchByte.Error> =
            Machine.Parser.build { builder in
                let a = Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
                    .map({ $0 }, in: &builder)
                let b = Machine.Parser.leaf(MatchByte(expected: 66), in: &builder)
                    .map({ $0 }, in: &builder)
                return Machine.Parser.oneOf([a, b], in: &builder)
            }

        var input = Input([66])
        let result = try parser.parse(&input)
        #expect(result == 66)
    }

    @Test
    func `many collects zero or more occurrences`() throws {
        let parser: Machine.Parser.Parser<Input, [UInt8], MatchByte.Error> =
            Machine.Parser.build { builder in
                let byte = Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
                    .map({ $0 }, in: &builder)
                return Machine.Parser.many(byte, in: &builder)
            }

        var input = Input([65, 65, 65, 66])
        let result = try parser.parse(&input)
        #expect(result == [65, 65, 65])
        #expect(input.remainingBytes() == [66])
    }

    @Test
    func `optional returns value on success`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8?, MatchByte.Error> =
            Machine.Parser.build { builder in
                let byte = Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
                    .map({ $0 }, in: &builder)
                return Machine.Parser.optional(byte, in: &builder)
            }

        var input = Input([65, 66])
        let result = try parser.parse(&input)
        #expect(result == 65)
        #expect(input.remainingBytes() == [66])
    }
}

extension Machine.Parser.Test.`Edge Case` {
    @Test
    func `many returns empty array when no matches`() throws {
        let parser: Machine.Parser.Parser<Input, [UInt8], MatchByte.Error> =
            Machine.Parser.build { builder in
                let byte = Machine.Parser.leaf(MatchByte(expected: 0xFF), in: &builder)
                    .map({ $0 }, in: &builder)
                return Machine.Parser.many(byte, in: &builder)
            }

        var input = Input([1, 2, 3])
        let result = try parser.parse(&input)
        #expect(result.isEmpty)
        #expect(input.remainingBytes() == [1, 2, 3])
    }

    @Test
    func `optional returns nil and restores input on failure`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8?, MatchByte.Error> =
            Machine.Parser.build { builder in
                let byte = Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
                    .map({ $0 }, in: &builder)
                return Machine.Parser.optional(byte, in: &builder)
            }

        var input = Input([66, 67])
        let result = try parser.parse(&input)
        #expect(result == nil)
        #expect(input.remainingBytes() == [66, 67])
    }

    @Test
    func `oneOf throws when all alternatives fail`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8, MatchByte.Error> =
            Machine.Parser.build { builder in
                let a = Machine.Parser.leaf(MatchByte(expected: 65), in: &builder)
                    .map({ $0 }, in: &builder)
                let b = Machine.Parser.leaf(MatchByte(expected: 66), in: &builder)
                    .map({ $0 }, in: &builder)
                return Machine.Parser.oneOf([a, b], in: &builder)
            }

        var input = Input([67])
        #expect(throws: MatchByte.Error.self) {
            _ = try parser.parse(&input)
        }
    }

    @Test
    func `many terminates when child succeeds without consuming input via pure`() throws {
        let parser: Machine.Parser.Parser<Input, [Int], ByteParser.Error> =
            Machine.Parser.build { builder in
                let p = Machine.Parser.pure(1, in: &builder)
                return Machine.Parser.many(p, in: &builder)
            }

        var input = Input([65, 66, 67])
        let result = try parser.parse(&input)
        #expect(result == [1])
        #expect(input.remainingBytes() == [65, 66, 67])
    }

    @Test
    func `many terminates when child succeeds without consuming input via optional`() throws {
        let parser: Machine.Parser.Parser<Input, [UInt8?], MatchByte.Error> =
            Machine.Parser.build { builder in
                let neverMatches = Machine.Parser.leaf(MatchByte(expected: 0xFF), in: &builder)
                    .map({ $0 }, in: &builder)
                let opt = Machine.Parser.optional(neverMatches, in: &builder)
                return Machine.Parser.many(opt, in: &builder)
            }

        var input = Input([1, 2, 3])
        let result = try parser.parse(&input)
        #expect(result == [nil])
        #expect(input.remainingBytes() == [1, 2, 3])
    }
}
