package import Machine
extension Machine.Parser.Memoization {

    package struct Table<Checkpoint: Hashable> {
        @usableFromInline
        var storage: [Key<Checkpoint>: Entry<Checkpoint>]

        package init() {
            self.storage = [:]
        }

        package init(capacity: Int) {
            self.storage = Dictionary(minimumCapacity: capacity)
        }
    }
}

extension Machine.Parser.Memoization.Table {
    package func lookup(
        _ key: Machine.Parser.Memoization.Key<Checkpoint>
    ) -> Machine.Parser.Memoization.Entry<Checkpoint>? {
        storage[key]
    }

    package mutating func store(
        _ entry: Machine.Parser.Memoization.Entry<Checkpoint>,
        for key: Machine.Parser.Memoization.Key<Checkpoint>
    ) {
        storage[key] = entry
    }
}

extension Machine.Parser.Memoization.Table {
    package var count: Int {
        storage.count
    }

    package var isEmpty: Bool {
        storage.isEmpty
    }

    package mutating func clear() {
        storage.removeAll(keepingCapacity: true)
    }
}

extension Machine.Parser.Memoization.Table where Checkpoint: Comparable {

    package mutating func invalidate(_ edit: Machine.Parser.Memoization.Edit<Checkpoint>) {
        storage = storage.filter { key, entry in
            switch entry {
            case .success(_, let endPosition):
                return endPosition <= edit.start

            case .failure:
                return key.position < edit.start
            }
        }
    }

    package mutating func invalidate(from position: Checkpoint) {
        storage = storage.filter { key, entry in
            switch entry {
            case .success(_, let endPosition):
                return endPosition <= position

            case .failure:
                return key.position < position
            }
        }
    }
}
