import Parser_Machine_Combinator
import Parser_Machine_Compile
import Parser_Test_Support

typealias Input = Parser.Test.Input

struct ByteParser: Parser.`Protocol`, Sendable {}

extension ByteParser {
    enum Error: Swift.Error, Sendable {
        case endOfInput
    }

    func parse(_ input: inout Input) throws(Error) -> UInt8 {
        guard let byte = input.first else {
            throw .endOfInput
        }

        _ = try? input.advance()
        return byte
    }
}

func makeInput(_ bytes: [UInt8]) -> Input {
    Input(bytes)
}
