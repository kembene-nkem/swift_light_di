//
//  File.swift
//  
//
//  Created by Kembene Nkem on 3/28/23.
//

import Foundation

/// Defines functionalities that can be used to persist Resolvers and resolved items.
public protocol InjectorStore {

  /// The number of resolvers that can resolve an object
  var resolversCount: Int { get }
  /// The number of objects that have been resolved
  var resolvedCount: Int { get }

  /// Tells the store to save a particular resolver identified by ``InjectIdentity``
  func putResolver<Value>(_ identifier: InjectIdentity<Value>, _ resolve: @escaping Resolver<Resolved>)

  /// Gets the ``Resolver`` registered for this ``InjectIdentity``
  func getResolver<Value>(_ identifier: InjectIdentity<Value>)-> Resolver<Resolved>?

  /// Removes all ``Resolver`` and ``Resolved`` associated with the specified ``InjectIdentity``
  /// - Parameters
  ///  - forIdentity: The identity whose ``Resolver`` and ``Resolved`` should be removed
  func remove<Value>(forIdentity: InjectIdentity<Value>)

  /// Removes all registered ``Resolver`` and ``Resolved``
  func removeAll()

  /// Get a ``Resolved`` value associated with the ``InjectIdentity``
  /// - returns: A value that has already been resolved
  func getResolved<Value>(_ identity: InjectIdentity<Value>) -> Resolved?

  /// Checks if there is an already resolved value with the specified identity
  func hasResolved<Value>(_ identity: InjectIdentity<Value>) -> Bool

  /// Puts a resolved value into the store
  func putResolved<Value>(_ identity: InjectIdentity<Value>, value: Resolved)
}


/// An InjectorStore that supports aliasing
public protocol AliasingInjectorStore: InjectorStore {
  /// Registers an alias identity `alias` to point to a `reference` identity
  func registerAlias<Alias, Reference>(_ alias: InjectIdentity<Alias>, reference: InjectIdentity<Reference>)

  /// Gets the ``Resolver`` this `alias` ``InjectIdentity`` points to
  func getAliasedResolver<Value>(_ identity: InjectIdentity<Value>)-> Resolver<Resolved>?

  /// Get a ``Resolved`` value associated with the `alias` InjectIdentity``
  /// - returns: A value that has already been resolved
  func getAliasedResolved<Value>(_ identity: InjectIdentity<Value>) -> Resolved?

  func putAliasedResolved<Value>(_ identity: InjectIdentity<Value>, value: Resolved)
}
