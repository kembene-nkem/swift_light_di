//
//  File.swift
//

import Foundation

/// A default implementation of the Injector protocol
public class LightInjector: Injector {

  public let store: InjectorStore

  public init(store: InjectorStore) {
    self.store = store
  }

  public func register<Value>(_ identity: InjectIdentity<Value>, _ value: Value) {
    store.putResolved(identity, value: value)
  }

  public func register<Value>(_ identity: InjectIdentity<Value>, _ resolver: @escaping Resolver<Value>) {
    store.putResolver(identity, resolver)
  }

  public func register<Value>(type: Value.Type? = nil, key: String? = nil, isPrototype: Bool = false, _ resolve: @escaping Resolver<Value>) {
    self.register(.of(type: type, key: key, isPrototype: isPrototype), resolve)
  }

  public func register<Value, Instance>(_ identity: InjectIdentity<Value>, instanceClass: Instance.Type) {
    var classInstance: AnyClass? = identity.typeToAutoCreate
    if classInstance == nil {
      let className = String(reflecting: instanceClass.self)
      classInstance = NSClassFromString(className)
    }
    if let classInstance {
      let resolver = ClassInstanceInitialize(classInstance: classInstance).getResolver(identity)
      register(identity, resolver)
    }
  }

  public func registerAlias<Alias, Reference>(_ alias: InjectIdentity<Alias>, reference: InjectIdentity<Reference>) {
    guard let aliasStore = store as? AliasingInjectorStore else { return }
    aliasStore.registerAlias(alias, reference: reference)
  }

  public func remove<Value>(_ identifier: InjectIdentity<Value>) {
    store.remove(forIdentity: identifier)
  }

  public func remove<Value>(type: Value.Type? = nil, key: String? = nil) {
    let identifier = InjectIdentity.of(type: type, key: key)
    self.remove(identifier)
  }

  public func removeAllDependencies() {
    store.removeAll()
  }

  public func resolve<Value>(type: Value.Type? = nil, key: String? = nil) throws -> Value {
    try self.resolveValue(.of(type: type, key: key))
  }

  public func resolveValue<Value>(_ identity: InjectIdentity<Value>) throws -> Value {
    try doValueResolution(identity)
  }

  func doValueResolution<Value>(_ identity: InjectIdentity<Value>) throws -> Value {
    /// if this identity has not been previously resolved by this injector, try to perform bean resolution. Else return the resolved bean
    guard let resolved = store.getResolved(identity) as? Value else {
      if let aliasedResolved = (store as? AliasingInjectorStore)?.getAliasedResolved(identity) as? Value {
        return aliasedResolved
      }
      return try performValueResolution(identity)
    }
    return resolved
  }

  private func performValueResolution<Value>(_ identity: InjectIdentity<Value>) throws -> Value {
    var resolver = store.getResolver(identity)
    var resolverWasFromAlias = false
    var resolvedWasFromAlias = false
    var resolved: Any?
    /// if there is not resolver already registered for this identity, check if it is aliased
    if resolver == nil, let aliasStore = store as? AliasingInjectorStore {
      resolver = aliasStore.getAliasedResolver(identity)
      resolverWasFromAlias = true
    }
    /// If there is no aliased resolver, then attempt to create a resolver that will automatically create an instance of the
    /// InjectIdentity.type
    if resolver == nil {
      resolver = self.attemptDynamicResolverRegistry(identity)
    }

    if let resolver {
      resolved = try resolver(self)
      resolvedWasFromAlias = resolverWasFromAlias
    } else {
      throw dependencyNotFound(identity: identity, error: nil)
    }

    guard let resolvedValue = resolved as? Value else {
      throw dependencyNotFound(identity: identity)
    }

    if identity.isPrototype == false {
      store.putResolved(identity, value: resolvedValue)
      if resolvedWasFromAlias == true {
        (store as? AliasingInjectorStore)?.putAliasedResolved(identity, value: resolvedValue)
      }
    }
    return resolvedValue
  }


  private func attemptDynamicResolverRegistry<Value>(_ identity: InjectIdentity<Value>)-> Resolver<Value>? {
    if let type = identity.type {
      let className = String(reflecting: type.self)
      if let classInstance = NSClassFromString(className) {
        let resolver = ClassInstanceInitialize(classInstance: classInstance).getResolver(identity)
        register(identity, resolver)
        return resolver
      }
    }
    return nil
  }

  func dependencyNotFound<Value>(identity: InjectIdentity<Value>, error: Error? = nil) -> Error {
    ResolvableError.dependencyNotFound(
      identity: .fromIdentity(identity: identity),
      friendlyMessage: nil,
      cause: nil
    )
  }
}

public struct ClassInstanceInitialize {
  let classInstance: AnyClass

  public init(classInstance: AnyClass) {
    self.classInstance = classInstance
  }

  public static func getInitializer<Instance>(instanceClass: Instance.Type) -> ClassInstanceInitialize? {
    let className = String(reflecting: instanceClass.self)
    if let classInstance = NSClassFromString(className) {
      return ClassInstanceInitialize(classInstance: classInstance)
    }
    return nil
  }

  public func getResolver<Value>(_ identity: InjectIdentity<Value>)-> ThrowableFunction<Resolvable, Value> {
    return { resolver in
      if let instanceClass = classInstance.self as? DynamicInitializerWithResolver.Type,
        let instance = instanceClass.init(resolver: resolver) as? Value {
        return instance
      }
      if let instanceClass = classInstance.self as? DynamicInitializer.Type,
        let instance = instanceClass.init() as? Value {
        return instance
      }
      throw ResolvableError.dependencyNotFound(
        identity: .fromIdentity(identity: identity),
        friendlyMessage: nil,
        cause: nil
      )
    }
  }
}
