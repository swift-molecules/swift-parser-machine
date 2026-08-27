extension Parser.Machine.Memoization {

    package struct Key<Checkpoint: Hashable>: Hashable {

        package let position: Checkpoint

        package let node: Ordinal

        package init(position: Checkpoint, node: Ordinal) {
            self.position = position
            self.node = node
        }
    }
}

extension Parser.Machine.Memoization.Key: Sendable where Checkpoint: Sendable {}
