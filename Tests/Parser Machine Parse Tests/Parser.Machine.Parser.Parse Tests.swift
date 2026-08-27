import Parser_Machine_Combinator
import Parser_Machine_Parse
import Parser_Test_Support
import Testing

@Suite
struct `Parser.Machine.Parser.Parse Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Parser.Machine.Parser.Parse Tests`.Unit {
    @Test
    func `parse accessor callAsFunction executes parser`() throws {
        let parser: Parser.Machine.Parser<Input, UInt8, ByteParser.Error> =
            Parser.Machine.build { builder in
                Parser.Machine.leaf(ByteParser(), in: &builder)
            }

        var input = Input([65])
        let result = try parser.parse(&input)
        #expect(result == 65)
    }
}
