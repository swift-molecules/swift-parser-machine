import Collection_Parser_Test_Support
import Machine
import Parser_Machine_Memoization
import Testing

@Suite
struct `Machine.Parser.Memoization.Edit Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Machine.Parser.Memoization.Edit Tests`.Unit {
    @Test
    func `init stores start, oldEnd, and newEnd`() {
        let edit = Machine.Parser.Memoization.Edit<Int>(start: 5, oldEnd: 10, newEnd: 8)
        #expect(edit.start == 5)
        #expect(edit.oldEnd == 10)
        #expect(edit.newEnd == 8)
    }

    @Test
    func `insert at position creates edit with same start and oldEnd`() {
        let insert = Machine.Parser.Memoization.Edit<Int>.insert(at: 10, length: 3)
        #expect(insert.start == 10)
        #expect(insert.oldEnd == 10)
        #expect(insert.newEnd == 13)
    }

    @Test
    func `delete from range creates edit with newEnd equal to start`() {
        let delete = Machine.Parser.Memoization.Edit<Int>.delete(from: 10, to: 15)
        #expect(delete.start == 10)
        #expect(delete.oldEnd == 15)
        #expect(delete.newEnd == 10)
    }
}

extension `Machine.Parser.Memoization.Edit Tests`.`Edge Case` {
    @Test
    func `insert with zero length is a no-op edit`() {
        let edit = Machine.Parser.Memoization.Edit<Int>.insert(at: 5, length: 0)
        #expect(edit.start == 5)
        #expect(edit.oldEnd == 5)
        #expect(edit.newEnd == 5)
    }

    @Test
    func `delete from same position is a no-op edit`() {
        let edit = Machine.Parser.Memoization.Edit<Int>.delete(from: 5, to: 5)
        #expect(edit.start == 5)
        #expect(edit.oldEnd == 5)
        #expect(edit.newEnd == 5)
    }
}
