public import Machine
@_exported import Parser

extension Parser {

    public enum Machine {}
}

extension Parser.Machine {

    public typealias Mode = Machine.Machine.Capture.Mode.Unchecked

    public typealias Value = Machine.Machine.Value<Mode>

    public typealias Transform = Machine.Machine.Transform

    public typealias Combine = Machine.Machine.Combine

    public typealias Finalize = Machine.Machine.Finalize

    public typealias Next = Machine.Machine.Next
}
