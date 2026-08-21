extension Parser.Machine.Memoization {

    package enum Entry<Checkpoint> {

        case success(output: Parser.Machine.Value, end: Checkpoint)

        case failure(any Swift.Error)
    }
}

extension Parser.Machine.Memoization.Entry {
    package var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    package var isFailure: Bool {
        switch self {
        case .success: return false
        case .failure: return true
        }
    }
}
