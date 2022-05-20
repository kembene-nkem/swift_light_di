//
//  File.swift

import Foundation

public typealias Resolved = Any
public typealias Resolver<Value> = ThrowableFunction<Resolvable, Value>

/// Defines an entity that can resolve a bean identified by an identity
public protocol Resolvable {
  /// Resolves a bean using the specified identity
  func resolveValue<Value>(_ identity: InjectIdentity<Value>) throws -> Value
  /// Resolves a bean by the specified type and key
  func resolve<Value>(type: Value.Type?, key: String?) throws -> Value
}

/// During bean registration, if you are not going to explicitly provide the instance of the bean, then the registered bean resolution type,
/// provided by either ``InjectIdentity.type`` or ``InjectIdentity.typeToAutoCreate`` must implement this protocol, so that
/// the DI container can create an instance of that type
public protocol DynamicInitializer {
  init()
}

/// During bean registration, if you are not going to explicitly provide the instance of the bean, then the registered bean resolution type,
/// provided by either ``InjectIdentity.type`` or ``InjectIdentity.typeToAutoCreate`` can implement this protocol, if the intializer
/// is going to have dependencies that needs to be resolved as well
public protocol DynamicInitializerWithResolver {
  init(resolver: Resolvable)
}
