package import Machine
extension Machine.Parser.Memoization {

    package struct Key<Checkpoint: Hashable>: Hashable {

        package let position: Checkpoint

        package let node: Ordinal

        package init(position: Checkpoint, node: Ordinal) {
            self.position = position
            self.node = node
        }
    }
}

extension Machine.Parser.Memoization.Key: Sendable where Checkpoint: Sendable {}
