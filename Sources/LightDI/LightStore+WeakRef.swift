//
//  LightStore+WeakRef.swift


import Foundation

/// A implementation of ``InjectorStore`` that keeps weak references of resolved objects
public class WeakReferenceInjectableStore {

  private var resolvers: [Int: Resolver<Any>] = [:]
  private var resolvedObjects: NSMapTable<NSString, AnyObject>
  private var aliases: [NSString: (NSString, Int)] = [:]

  public var resolversCount: Int { resolvers.count }
  public var resolvedCount: Int { resolvedObjects.count }

  public init(strongReferences: Bool = false) {
      resolvedObjects = strongReferences ? NSMapTable<NSString, AnyObject>()
    : NSMapTable<NSString, AnyObject>(keyOptions: .copyIn, valueOptions: .weakMemory)
  }
}

extension WeakReferenceInjectableStore: InjectorStore {

  public func putResolver<Value>(_ identifier: InjectIdentity<Value>, _ resolve: @escaping Resolver<Any>) {
    resolvers[identifier.hashValue] = resolve
  }

  public func getResolver<Value>(_ identifier: InjectIdentity<Value>)-> Resolver<Any>? {
    resolvers[identifier.hashValue]
  }

  public func remove<Value>(forIdentity: InjectIdentity<Value>) {
    resolvers.removeValue(forKey: forIdentity.hashValue)
      resolvedObjects.removeObject(forKey: forIdentity.asNSString())
  }

  public func removeAll() {
      resolvers.removeAll()
      resolvedObjects.removeAllObjects()
  }

  public func getResolved<Value>(_ identity: InjectIdentity<Value>) -> Any? {
      return resolvedObjects.object(forKey: identity.asNSString())
  }

  public func hasResolved<Value>(_ identity: InjectIdentity<Value>) -> Bool {
      resolvedObjects.object(forKey: identity.asNSString()) != nil
  }

  public func putResolved<Value>(_ identity: InjectIdentity<Value>, value: Any) {
      resolvedObjects.setObject(value as AnyObject, forKey: identity.asNSString())
  }
}

extension WeakReferenceInjectableStore: AliasingInjectorStore {
  public func registerAlias<Alias, Reference>(_ alias: InjectIdentity<Alias>, reference: InjectIdentity<Reference>) {
    aliases[alias.asNSString()] = (reference.asNSString(), reference.hashValue)
  }

  public func getAliasedResolver<Value>(_ identity: InjectIdentity<Value>)-> Resolver<Resolved>? {
    guard let reference = aliases[identity.asNSString()] else {
      return nil
    }
    return resolvers[reference.1]
  }

  public func putAliasedResolved<Value>(_ identity: InjectIdentity<Value>, value: Resolved) {
    guard let reference = aliases[identity.asNSString()] else {
      return
    }
    if resolvedObjects.object(forKey: reference.0) == nil {
      resolvedObjects.setObject(value as AnyObject, forKey: reference.0)
    }
  }

  public func getAliasedResolved<Value>(_ identity: InjectIdentity<Value>) -> Resolved? {
    guard let reference = aliases[identity.asNSString()] else {
      return nil
    }
    return resolvedObjects.object(forKey: reference.0)
  }
}
