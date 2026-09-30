import Collection_Parser_Test_Support
import Machine
import Parser_Machine_Program
import Testing

@Suite
struct `Machine.Parser.Value Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Machine.Parser.Value Tests`.Unit {
    @Test
    func `make and subscript preserves integer value`() {
        let value = Machine.Parser.Value.make(42)
        #expect(value[as: Int.self] == 42)
    }

    @Test
    func `make and subscript preserves string value`() {
        let value = Machine.Parser.Value.make("hello")
        #expect(value[as: String.self] == "hello")
    }
}

extension `Machine.Parser.Value Tests`.`Edge Case` {
    @Test
    func `subscript with wrong type traps`() {
        let value = Machine.Parser.Value.make(42)
        #expect(value[as: Int.self] == 42)
    }
}
