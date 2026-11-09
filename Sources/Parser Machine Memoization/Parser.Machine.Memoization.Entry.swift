package import Machine
extension Machine.Parser.Memoization {

    package enum Entry<Checkpoint> {

        case success(output: Machine.Parser.Value, end: Checkpoint, reach: Checkpoint)

        case failure(any Swift::Error, reach: Checkpoint)
    }
}

extension Machine.Parser.Memoization.Entry {
    package var reach: Checkpoint {
        switch self {
        case .success(_, _, let reach): return reach
        case .failure(_, let reach): return reach
        }
    }

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
