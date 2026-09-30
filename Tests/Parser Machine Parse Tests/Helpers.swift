public import Ordinal
public import Index
public import Iterator
public import Cursor
public import Checkpoint
import Parser_Machine_Combinator
import Parser_Machine_Parse
public import Collection_Parser_Test_Support

typealias Input = CollectionParserTest.Input

struct ByteParser: Parsing, Sendable {}

extension ByteParser {
    enum Error: Swift.Error, Sendable {
        case endOfInput
    }

    func parse(_ input: inout Input) throws(Error) -> UInt8 {
        guard let byte = input.first else {
            throw .endOfInput
        }

        input = input[input.index(after: input.startIndex)..<input.endIndex]
        return byte
    }
}

struct MatchByte: Parsing, Sendable {
    let expected: UInt8
}

extension MatchByte {
    enum Error: Swift.Error, Sendable {
        case mismatch(expected: UInt8, actual: UInt8?)
    }

    func parse(_ input: inout Input) throws(Error) -> UInt8 {
        guard let byte = input.first else {
            throw .mismatch(expected: expected, actual: nil)
        }
        guard byte == expected else {
            throw .mismatch(expected: expected, actual: byte)
        }

        input = input[input.index(after: input.startIndex)..<input.endIndex]
        return byte
    }
}

func makeInput(_ bytes: [UInt8]) -> Input {
    Input(bytes)
}

func makeInput(_ string: Swift.String) -> Input {
    Input(utf8: string)
}

extension CollectionParserTest.Input: @retroactive Iterator.`Protocol`, @retroactive Restorable, @retroactive Cursor.`Protocol` {
    public typealias Failure = Never

    public var checkpoint: Int { Int(bitPattern: startIndex.underlying.rawValue) }

    public mutating func seek(to checkpoint: Int) {
        self = self[Index::Index<UInt8>(_unchecked: Ordinal::Ordinal(UInt(checkpoint)))..<endIndex]
    }

    public mutating func next() -> UInt8? {
        guard let element = first else { return nil }
        self = self[index(after: startIndex)..<endIndex]
        return element
    }
}

extension CollectionParserTest.Input: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        var position = startIndex
        while position < endIndex {
            hasher.combine(self[position])
            position = index(after: position)
        }
    }
}
