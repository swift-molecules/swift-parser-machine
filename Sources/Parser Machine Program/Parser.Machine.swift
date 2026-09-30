public import Machine
@_exported import Parser

extension Machine::Machine {

    public enum Parser {}
}

extension Machine.Parser {

    public typealias Mode = Machine::Machine.Capture.Mode.Unchecked

    public typealias Value = Machine::Machine.Value<Mode>

    public typealias Transform = Machine::Machine.Transform

    public typealias Combine = Machine::Machine.Combine

    public typealias Finalize = Machine::Machine.Finalize

    public typealias Next = Machine::Machine.Next
}
