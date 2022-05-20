/// Defines a function that takes a parameter `I` and returns `O` and is capable of throwing
public typealias ThrowableFunction<I, O> = (I) throws -> O

public struct LightDI {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}
