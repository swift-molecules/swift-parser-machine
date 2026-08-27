extension Parser.Machine.Memoization {

    public struct Edit<Checkpoint: Comparable> {

        public let start: Checkpoint

        public let oldEnd: Checkpoint

        public let newEnd: Checkpoint

        @inlinable
        public init(start: Checkpoint, oldEnd: Checkpoint, newEnd: Checkpoint) {
            self.start = start
            self.oldEnd = oldEnd
            self.newEnd = newEnd
        }
    }
}

extension Parser.Machine.Memoization.Edit: Sendable where Checkpoint: Sendable {}

extension Parser.Machine.Memoization.Edit where Checkpoint: Numeric {

    @inlinable
    public static func insert(at position: Checkpoint, length: Checkpoint) -> Self {
        Self(start: position, oldEnd: position, newEnd: position + length)
    }
}

extension Parser.Machine.Memoization.Edit {

    @inlinable
    public static func delete(from start: Checkpoint, to end: Checkpoint) -> Self {
        Self(start: start, oldEnd: end, newEnd: start)
    }
}
