package import Machine
extension Machine.Parser.Memoization {

    package enum Entry<Checkpoint> {

        case success(output: Machine.Parser.Value, end: Checkpoint)

        case failure(any Swift.Error)
    }
}

extension Machine.Parser.Memoization.Entry {
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
