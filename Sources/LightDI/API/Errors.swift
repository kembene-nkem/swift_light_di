//
//  File.swift


import Foundation

public protocol ApplicationError: Swift.Error {
    var errorCode: String { get }
    var errorMessage: String? { get }
    var userFriendlyMessage: String? { get }
}

public enum ResolvableError {
    case dependencyNotFound(identity: IdentityInfo, friendlyMessage: String?, cause: Error?)

    public struct IdentityInfo {
        public var type: Any.Type?
        public var key: String?
        public var forceRecreate: Bool

        public init(type: Any.Type? = nil, key: String? = nil, forceRecreate: Bool = false) {
            self.type = type
            self.key = key
            self.forceRecreate = forceRecreate
        }

        public static func fromIdentity<Value>(identity: InjectIdentity<Value>) -> IdentityInfo {
            .init(type: identity.type,
                  key: identity.key,
                  forceRecreate: identity.isPrototype
            )
        }
    }

    private func code() -> String {
        switch self {
        case .dependencyNotFound:
            return "dependencyNotFound"
        }
    }

    private func userMessage() -> String? {
        switch self {
        case let .dependencyNotFound(info, message, _):
            if message != nil {
                return message
            }
            var message = "Could not find dependency for "
            if let type = info.type {
                message += "type: \(type) "
            }
            if let key = info.key {
                message += "key: \(key) "
            }
            message += "recreating: \(info.forceRecreate)"
            return message
        }
    }

    private func error() -> String? {
        switch self {
        case .dependencyNotFound(_, _, let cause):
            var message = userMessage() ?? ""
            if let cause = cause {
                message += "\(cause)"
            }
            return message
        }
    }
}

extension ResolvableError: ApplicationError, LocalizedError {
    public var errorCode: String {
        self.code()
    }

    public var errorMessage: String? {
        error()
    }

    public var userFriendlyMessage: String? {
        userMessage()
    }

    public var errorDescription: String? {
        errorMessage ?? String(describing: self)
    }

}
