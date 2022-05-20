//
//  File.swift

import Foundation

/// Provide a ``InjectorStore`` implementation. This implementation uses a `Dictionary` to keep
/// ``Resolver`` and ``Resolved`` values
public class DefaultInjectorStore {
  private var resolvers: [AnyHashable: Resolver<Any>] = [:]
  private var resolved: [AnyHashable: Any] = [:]
  private var aliases: [AnyHashable: AnyHashable] = [:]

  public var resolversCount: Int { resolvers.count }
  public var resolvedCount: Int { resolved.count }

  public init() {}
}

extension DefaultInjectorStore: InjectorStore {
  public func putResolver<Value>(_ identifier: InjectIdentity<Value>, _ resolve: @escaping Resolver<Any>) {
    resolvers[identifier] = resolve
  }

  public func getResolver<Value>(_ identifier: InjectIdentity<Value>)-> Resolver<Any>? {
    resolvers[identifier]
  }

  public func remove<Value>(forIdentity: InjectIdentity<Value>) {
    resolvers.removeValue(forKey: forIdentity)
    resolved.removeValue(forKey: forIdentity)
  }

  public func removeAll() {
    resolvers.removeAll()
    resolved.removeAll()
  }

  public func getResolved<Value>(_ identity: InjectIdentity<Value>) -> Any? {
    resolved[identity] as? Value
  }

  public func hasResolved<Value>(_ identity: InjectIdentity<Value>) -> Bool {
    (resolved[identity] as? Value) != nil
  }

  public func putResolved<Value>(_ identity: InjectIdentity<Value>, value: Any) {
    resolved[identity] = value
  }
}

extension DefaultInjectorStore: AliasingInjectorStore {
  public func registerAlias<Alias, Reference>(_ alias: InjectIdentity<Alias>, reference: InjectIdentity<Reference>) {
    aliases[alias] = reference
  }

  public func getAliasedResolver<Value>(_ identity: InjectIdentity<Value>)-> Resolver<Resolved>? {
    guard let reference = aliases[identity] else {
      return nil
    }
    return resolvers[reference]
  }

  public func putAliasedResolved<Value>(_ identity: InjectIdentity<Value>, value: Resolved) {
    guard let reference = aliases[identity] else {
      return
    }
    if resolved[reference] == nil && (value as? Value) != nil{
      resolved[reference] = value
    }
  }

  public func getAliasedResolved<Value>(_ identity: InjectIdentity<Value>) -> Resolved? {
    guard let reference = aliases[identity.asNSString()] else {
      return nil
    }
    return resolved[reference]
  }
}
