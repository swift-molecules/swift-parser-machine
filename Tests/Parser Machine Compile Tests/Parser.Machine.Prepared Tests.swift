import Parser_Machine_Combinator
import Parser_Machine_Compile
import Parser_Test_Support
import Testing

@Suite
struct `Parser.Machine.Prepared Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Parser.Machine.Prepared Tests`.Unit {
    @Test
    func `prepared parser eagerly compiles from source`() throws {
        let prepared = Parser.Machine.Prepared(source: ByteParser(), witness: .leaf)

        var input = Input([65])
        let result = try prepared.parse(&input)
        #expect(result == 65)
    }

    @Test
    func `prepared parser parses multiple inputs`() throws {
        let prepared = Parser.Machine.Prepared(source: ByteParser(), witness: .leaf)

        var input1 = Input([10])
        let result1 = try prepared.parse(&input1)

        var input2 = Input([20])
        let result2 = try prepared.parse(&input2)

        #expect(result1 == 10)
        #expect(result2 == 20)
    }
}

extension `Parser.Machine.Prepared Tests`.`Edge Case` {
    @Test
    func `prepared parser throws on empty input`() {
        let prepared = Parser.Machine.Prepared(source: ByteParser(), witness: .leaf)

        var input = Input([])
        #expect(throws: ByteParser.Error.self) {
            _ = try prepared.parse(&input)
        }
    }
}
