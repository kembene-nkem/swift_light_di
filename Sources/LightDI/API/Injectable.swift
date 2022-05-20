//
//  File.swift


import Foundation

public protocol Injectable: Resolvable {

  func register<Value>(_ identity: InjectIdentity<Value>, _ value: Value)
  func register<Value>(_ identity: InjectIdentity<Value>, _ resolver: @escaping Resolver<Value>)
  func register<Value, Instance>(_ identity: InjectIdentity<Value>, instanceClass: Instance.Type)
  func registerAlias<Alias, Reference>(_ alias: InjectIdentity<Alias>, reference: InjectIdentity<Reference>)
  func remove<Value>(_ identifier: InjectIdentity<Value>)
}

public protocol Injector: AnyObject, Injectable, Resolvable {
  var store: InjectorStore { get }
}
