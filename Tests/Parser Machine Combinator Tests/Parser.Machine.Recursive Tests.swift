import Collection_Parser_Test_Support
import Machine
import Parser_Machine_Combinator
import Parser_Machine_Parse
import Parser_Test_Support
import Testing

private struct OpenParen: Parsing, Sendable {
}

extension OpenParen {
    enum Error: Swift.Error, Sendable { case expected }

    func parse(_ input: inout Input) throws(Error) {
        guard input.first == UInt8(ascii: "(") else { throw .expected }

        input = input[input.index(after: input.startIndex)..<input.endIndex]
    }
}

private struct CloseParen: Parsing, Sendable {
}

extension CloseParen {
    enum Error: Swift.Error, Sendable { case expected }

    func parse(_ input: inout Input) throws(Error) {
        guard input.first == UInt8(ascii: ")") else { throw .expected }

        input = input[input.index(after: input.startIndex)..<input.endIndex]
    }
}

private enum ParenError: Swift.Error, Sendable {
    case openParen
    case closeParen
}

private func balancedParenParser(
    maxDepth: Int
) -> Machine.Parser.Parser<Input, Int, ParenError> {
    Machine.Parser.recursive(maxDepth: maxDepth) { builder, selfRef in
        let empty = Machine.Parser.pure(0, in: &builder)
        let open = Machine.Parser.leaf(
            OpenParen(),
            mapError: { _ in ParenError.openParen },
            in: &builder
        )
        let close = Machine.Parser.leaf(
            CloseParen(),
            mapError: { _ in ParenError.closeParen },
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
}

private struct XMLElement: Sendable, Equatable {
    var name: String
    var content: [XMLContent]
}

private enum XMLContent: Sendable, Equatable {
    case element(XMLElement)
}

private struct OpenBracket: Parsing, Sendable {
}

extension OpenBracket {
    enum Error: Swift.Error, Sendable { case expected }
    func parse(_ input: inout Input) throws(Error) {
        guard input.first == UInt8(ascii: "<") else { throw .expected }

        input = input[input.index(after: input.startIndex)..<input.endIndex]
    }
}

private struct CloseBracket: Parsing, Sendable {
}

extension CloseBracket {
    enum Error: Swift.Error, Sendable { case expected }
    func parse(_ input: inout Input) throws(Error) {
        guard input.first == UInt8(ascii: ">") else { throw .expected }

        input = input[input.index(after: input.startIndex)..<input.endIndex]
    }
}

private struct SlashClose: Parsing, Sendable {
}

extension SlashClose {
    enum Error: Swift.Error, Sendable { case expected }
    func parse(_ input: inout Input) throws(Error) {
        guard input.first == UInt8(ascii: "/") else { throw .expected }

        input = input[input.index(after: input.startIndex)..<input.endIndex]
        guard input.first == UInt8(ascii: ">") else { throw .expected }

        input = input[input.index(after: input.startIndex)..<input.endIndex]
    }
}

private struct StartTagOutput: Sendable {
    var isEmpty: Bool
}

private struct ParseOpen: Parsing, Sendable {
}

extension ParseOpen {
    enum Error: Swift.Error, Sendable { case expected }
    func parse(_ input: inout Input) throws(Error) -> StartTagOutput {
        guard input.first == UInt8(ascii: "<") else { throw .expected }

        input = input[input.index(after: input.startIndex)..<input.endIndex]
        guard input.first == UInt8(ascii: "/") else {
            return StartTagOutput(isEmpty: false)
        }

        input = input[input.index(after: input.startIndex)..<input.endIndex]
        guard input.first == UInt8(ascii: ">") else { throw .expected }

        input = input[input.index(after: input.startIndex)..<input.endIndex]
        return StartTagOutput(isEmpty: true)
    }
}

private struct ParseClose: Parsing, Sendable {
}

extension ParseClose {
    enum Error: Swift.Error, Sendable { case expected }
    func parse(_ input: inout Input) throws(Error) {
        guard input.first == UInt8(ascii: ">") else { throw .expected }

        input = input[input.index(after: input.startIndex)..<input.endIndex]
    }
}

extension Machine.Parser.Test {
    @Suite struct Recursive {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

extension Machine.Parser.Test.Recursive.Unit {
    @Test
    func `balanced parentheses parses three levels`() throws {
        let parser = balancedParenParser(maxDepth: 1000)

        var input = makeInput("((()))")
        let depth = try parser.parse(&input)
        #expect(depth == 3)
        #expect(input.first == nil)
    }

    @Test
    func `balanced parentheses parses 100 levels`() throws {
        let parser = balancedParenParser(maxDepth: 1000)

        var bytes: [UInt8] = []
        for _ in 0..<100 { bytes.append(UInt8(ascii: "(")) }
        for _ in 0..<100 { bytes.append(UInt8(ascii: ")")) }

        var input = makeInput(bytes)
        let depth = try parser.parse(&input)
        #expect(depth == 100)
        #expect(input.first == nil)
    }

    @Test
    func `build creates non-recursive parser`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8, ByteParser.Error> =
            Machine.Parser.build { builder in
                Machine.Parser.leaf(ByteParser(), in: &builder)
            }

        var input = Input([42])
        let result = try parser.parse(&input)
        #expect(result == 42)
    }
}

extension Machine.Parser.Test.Recursive.Integration {
    @Test
    func `deep nesting 2000 levels without stack overflow`() throws {
        let parser = balancedParenParser(maxDepth: 10000)

        var bytes: [UInt8] = []
        for _ in 0..<2000 { bytes.append(UInt8(ascii: "(")) }
        for _ in 0..<2000 { bytes.append(UInt8(ascii: ")")) }

        var input = makeInput(bytes)
        let depth = try parser.parse(&input)
        #expect(depth == 2000)
        #expect(input.first == nil)
    }

    @Test
    func `deep nesting 5000 levels without stack overflow`() throws {
        let parser = balancedParenParser(maxDepth: 10000)

        var bytes: [UInt8] = []
        for _ in 0..<5000 { bytes.append(UInt8(ascii: "(")) }
        for _ in 0..<5000 { bytes.append(UInt8(ascii: ")")) }

        var input = makeInput(bytes)
        let depth = try parser.parse(&input)
        #expect(depth == 5000)
        #expect(input.first == nil)
    }

    @Test
    func `deep nesting with complex types 1000 levels`() throws {
        let parser: Machine.Parser.Parser<Input, XMLElement, ParenError> =
            Machine.Parser.recursive(maxDepth: 2000) { builder, selfRef in
                let open = Machine.Parser.leaf(
                    OpenBracket(),
                    mapError: { _ in ParenError.openParen },
                    in: &builder
                )
                let close = Machine.Parser.leaf(
                    CloseBracket(),
                    mapError: { _ in ParenError.closeParen },
                    in: &builder
                )
                let slashClose = Machine.Parser.leaf(
                    SlashClose(),
                    mapError: { _ in ParenError.closeParen },
                    in: &builder
                )

                let elementContent = selfRef.expression(in: &builder)
                    .map({ XMLContent.element($0) }, in: &builder)

                let content = Machine.Parser.many(elementContent, in: &builder)

                let openWithContent = Machine.Parser.sequence(
                    open,
                    content,
                    combine: { (_: Void, c: [XMLContent]) in c },
                    in: &builder
                )
                let nonEmpty = Machine.Parser.sequence(
                    openWithContent,
                    close,
                    combine: { (contents: [XMLContent], _: Void) in
                        XMLElement(name: "e", content: contents)
                    },
                    in: &builder
                )

                let emptyElement = Machine.Parser.sequence(
                    open,
                    slashClose,
                    combine: { (_: Void, _: Void) in
                        XMLElement(name: "e", content: [])
                    },
                    in: &builder
                )

                return Machine.Parser.oneOf([nonEmpty, emptyElement], in: &builder)
            }

        var bytes: [UInt8] = []
        for _ in 0..<1000 { bytes.append(UInt8(ascii: "<")) }
        bytes.append(UInt8(ascii: "/"))
        bytes.append(UInt8(ascii: ">"))
        for _ in 0..<999 { bytes.append(UInt8(ascii: ">")) }

        var input = makeInput(bytes)
        let result = try parser.parse(&input)
        #expect(result.name == "e")
        #expect(input.isEmpty)
    }

    @Test
    func `deep nesting with tryMap disambiguation 50 levels`() throws {
        let parser: Machine.Parser.Parser<Input, XMLElement, ParenError> =
            Machine.Parser.recursive(maxDepth: 100) { builder, selfRef in
                let startTag = Machine.Parser.leaf(
                    ParseOpen(),
                    mapError: { _ in ParenError.openParen },
                    in: &builder
                )
                let endTag = Machine.Parser.leaf(
                    ParseClose(),
                    mapError: { _ in ParenError.closeParen },
                    in: &builder
                )

                let emptyElement = startTag.tryMap(
                    { (start: StartTagOutput) throws(ParenError) -> XMLElement in
                        guard start.isEmpty else { throw ParenError.openParen }
                        return XMLElement(name: "e", content: [])
                    },
                    in: &builder
                )

                let openTag = startTag.tryMap(
                    { (start: StartTagOutput) throws(ParenError) -> StartTagOutput in
                        guard !start.isEmpty else { throw ParenError.closeParen }
                        return start
                    },
                    in: &builder
                )

                let elementContent = selfRef.expression(in: &builder)
                    .map({ XMLContent.element($0) }, in: &builder)

                let content = Machine.Parser.many(elementContent, in: &builder)

                let withContent = Machine.Parser.sequence(
                    openTag,
                    content,
                    combine: { (_: StartTagOutput, c: [XMLContent]) in c },
                    in: &builder
                )
                let nonEmptyElement = Machine.Parser.sequence(
                    withContent,
                    endTag,
                    combine: { (contents: [XMLContent], _: Void) in
                        XMLElement(name: "e", content: contents)
                    },
                    in: &builder
                )

                return Machine.Parser.oneOf([emptyElement, nonEmptyElement], in: &builder)
            }

        var bytes: [UInt8] = []
        for _ in 0..<50 { bytes.append(UInt8(ascii: "<")) }
        bytes.append(UInt8(ascii: "/"))
        bytes.append(UInt8(ascii: ">"))
        for _ in 0..<49 { bytes.append(UInt8(ascii: ">")) }

        var input = makeInput(bytes)
        let result = try parser.parse(&input)
        #expect(result.name == "e")
        #expect(input.isEmpty)
    }
}

private enum DepthError: Swift.Error, Equatable, Sendable {
    case tooDeep(limit: Int)
    case openParen
}

private func unrecoverableRecursionParser(
    maxDepth: Int
) -> Machine.Parser.Parser<Input, Int, DepthError> {
    Machine.Parser.recursive(
        maxDepth: maxDepth,
        onDepthExceeded: { DepthError.tooDeep(limit: $0) },
        { builder, selfRef in
            let open = Machine.Parser.leaf(
                OpenParen(),
                mapError: { _ in DepthError.openParen },
                in: &builder
            )
            let inner = selfRef.expression(in: &builder)
            return Machine.Parser.sequence(
                open,
                inner,
                combine: { (_: Void, value: Int) in value },
                in: &builder
            )
        }
    )
}

extension Machine.Parser.Test.Recursive.`Edge Case` {
    @Test
    func `exceeding the depth limit with no recovery throws the configured typed failure`() throws {
        let parser = unrecoverableRecursionParser(maxDepth: 4)

        var bytes: [UInt8] = []
        for _ in 0..<10 { bytes.append(UInt8(ascii: "(")) }
        var input = makeInput(bytes)

        #expect(throws: DepthError.tooDeep(limit: 4)) {
            _ = try parser.parse(&input)
        }
    }

    @Test
    func `exceeding the depth limit with no recovery throws through the incremental path`() throws {
        let parser = unrecoverableRecursionParser(maxDepth: 4)
        var ctx = parser.parse.incremental

        var bytes: [UInt8] = []
        for _ in 0..<10 { bytes.append(UInt8(ascii: "(")) }
        var input = makeInput(bytes)

        #expect(throws: DepthError.tooDeep(limit: 4)) {
            _ = try ctx(&input)
        }
    }

    @Test
    func `input shorter than the depth limit still fails with the grammar's own error`() throws {
        let parser = unrecoverableRecursionParser(maxDepth: 100)

        var bytes: [UInt8] = []
        for _ in 0..<3 { bytes.append(UInt8(ascii: "(")) }
        var input = makeInput(bytes)

        #expect(throws: DepthError.openParen) {
            _ = try parser.parse(&input)
        }
    }
}
