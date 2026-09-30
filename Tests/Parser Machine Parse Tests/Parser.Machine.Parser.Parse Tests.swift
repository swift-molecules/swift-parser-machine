import Collection_Parser_Test_Support
import Machine
import Parser_Machine_Combinator
import Parser_Machine_Parse
import Parser_Test_Support
import Testing

@Suite
struct `Machine.Parser.Parser.Parse Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Machine.Parser.Parser.Parse Tests`.Unit {
    @Test
    func `parse accessor callAsFunction executes parser`() throws {
        let parser: Machine.Parser.Parser<Input, UInt8, ByteParser.Error> =
            Machine.Parser.build { builder in
                Machine.Parser.leaf(ByteParser(), in: &builder)
            }

        var input = Input([65])
        let result = try parser.parse(&input)
        #expect(result == 65)
    }
}
