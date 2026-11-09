import Collection_Parser_Test_Support
import Machine
import Parser_Machine_Memoization
import Tagged_Test_Support
import Testing

private enum TestFailure: Swift::Error, Sendable {
    case sample
}

@Suite
struct `Machine.Parser.Memoization.Table Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Machine.Parser.Memoization.Table Tests`.Unit {
    @Test
    func `new table is empty`() {
        let table = Machine.Parser.Memoization.Table<Int>()
        #expect(table.isEmpty)
        #expect(table.count == 0)
    }

    @Test
    func `new table with capacity is empty`() {
        let table = Machine.Parser.Memoization.Table<Int>(capacity: 100)
        #expect(table.isEmpty)
        #expect(table.count == 0)
    }

    @Test
    func `store and lookup returns entry`() {
        var table = Machine.Parser.Memoization.Table<Int>()
        let key = Machine.Parser.Memoization.Key<Int>(position: 0, node: 1)
        let entry = Machine.Parser.Memoization.Entry<Int>.failure(TestFailure.sample, reach: 0)

        table.store(entry, for: key)
        let result = table.lookup(key)
        #expect(result != nil)
    }

    @Test
    func `count reflects stored entries`() {
        var table = Machine.Parser.Memoization.Table<Int>()
        let key1 = Machine.Parser.Memoization.Key<Int>(position: 0, node: 1)
        let key2 = Machine.Parser.Memoization.Key<Int>(position: 1, node: 1)

        table.store(.failure(TestFailure.sample, reach: 0), for: key1)
        table.store(.failure(TestFailure.sample, reach: 1), for: key2)
        #expect(table.count == 2)
    }

    @Test
    func `clear removes all entries`() {
        var table = Machine.Parser.Memoization.Table<Int>()
        let key = Machine.Parser.Memoization.Key<Int>(position: 0, node: 1)
        table.store(.failure(TestFailure.sample, reach: 0), for: key)
        #expect(!table.isEmpty)

        table.clear()
        #expect(table.isEmpty)
        #expect(table.count == 0)
    }
}

extension `Machine.Parser.Memoization.Table Tests`.`Edge Case` {
    @Test
    func `lookup for missing key returns nil`() {
        let table = Machine.Parser.Memoization.Table<Int>()
        let key = Machine.Parser.Memoization.Key<Int>(position: 0, node: 1)
        #expect(table.lookup(key) == nil)
    }

    @Test
    func `store overwrites existing entry for same key`() {
        var table = Machine.Parser.Memoization.Table<Int>()
        let key = Machine.Parser.Memoization.Key<Int>(position: 0, node: 1)

        table.store(.failure(TestFailure.sample, reach: 0), for: key)
        #expect(table.lookup(key)?.isFailure == true)

        let value = Machine.Parser.Value.make(42)
        table.store(.success(output: value, end: 1, reach: 1), for: key)
        #expect(table.lookup(key)?.isSuccess == true)
        #expect(table.count == 1)
    }

    @Test
    func `invalidate from position removes entries at or after`() {
        var table = Machine.Parser.Memoization.Table<Int>()
        let key0 = Machine.Parser.Memoization.Key<Int>(position: 0, node: 1)
        let key5 = Machine.Parser.Memoization.Key<Int>(position: 5, node: 1)
        let key10 = Machine.Parser.Memoization.Key<Int>(position: 10, node: 1)

        table.store(.failure(TestFailure.sample, reach: 0), for: key0)
        table.store(.failure(TestFailure.sample, reach: 5), for: key5)
        table.store(.failure(TestFailure.sample, reach: 10), for: key10)
        #expect(table.count == 3)

        table.invalidate(from: 5)
        #expect(table.count == 1)
        #expect(table.lookup(key0) != nil)
        #expect(table.lookup(key5) == nil)
        #expect(table.lookup(key10) == nil)
    }

    @Test
    func `invalidate with edit removes overlapping entries`() {
        var table = Machine.Parser.Memoization.Table<Int>()
        let key0 = Machine.Parser.Memoization.Key<Int>(position: 0, node: 1)
        let key5 = Machine.Parser.Memoization.Key<Int>(position: 5, node: 1)
        let key15 = Machine.Parser.Memoization.Key<Int>(position: 15, node: 1)

        table.store(.failure(TestFailure.sample, reach: 0), for: key0)
        table.store(.failure(TestFailure.sample, reach: 5), for: key5)
        table.store(.failure(TestFailure.sample, reach: 15), for: key15)
        #expect(table.count == 3)

        let edit = Machine.Parser.Memoization.Edit<Int>(start: 5, oldEnd: 10, newEnd: 8)
        table.invalidate(edit)

        #expect(table.lookup(key0) != nil)
        #expect(table.lookup(key5) == nil)
    }

    @Test
    func `invalidate removes a failure that started before the edit but read across it`() {
        var table = Machine.Parser.Memoization.Table<Int>()
        let key = Machine.Parser.Memoization.Key<Int>(position: 0, node: 1)
        table.store(.failure(TestFailure.sample, reach: 7), for: key)

        table.invalidate(.init(start: 5, oldEnd: 6, newEnd: 6))
        #expect(table.lookup(key) == nil)
    }
}
