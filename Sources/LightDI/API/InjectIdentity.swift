//
//  InjectIdentity.swift

import Foundation

/**
Used to identify a bean that would be registered in the DI container. Use this to register your bean with the DI container
 */
public struct InjectIdentity<Value> {

  /// The bean type that the DI container will resolve this identity to. This could be a protocol or a class.
  /// If it's a protocol, then ensure to provide a typeToAutoCreate property (i.e if you are not providing the instance yourself)
  public let type: Value.Type?
  /// A key that can be used to identify this identity.
  public let key: String?
  /// The type to auto-create. If this property is specified, that an instance of this type is what will be auto created during resolution time
  public let typeToAutoCreate: AnyClass?
  /// States if a new instance will always be created each time it's injected. Defaults to false
  public let isPrototype: Bool

  /// Instantiates a new `InjectIdentity` that can be used to register a bean
  /// - Parameters:
  ///  - type: The bean type that will be associated with this bean. This type can then be used to resolve the bean during bean resolution
  ///   if this is a protocol, then you must either provide a `typeToAutoCreate` parameter, or provide an instance of the bean itself during registration
  ///  - key: A key to use for the registration. This can become important if you have multiple registration with the same type but different implementation
  ///  - isPrototype: If a new instance will always be created each time a resolution is made
  ///  - typeToAutoCreate: Use this to specify the instance class that will be created during resolution time, if the instance type is going to be different from the value type
  private init(type: Value.Type? = nil, key: String? = nil, isPrototype: Bool = false, typeToAutoCreate: AnyClass? = nil) {
    self.type = type
    self.key = key
    self.typeToAutoCreate = typeToAutoCreate
    self.isPrototype = isPrototype
  }
}

extension InjectIdentity: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.key)
    if let type = self.type {
      hasher.combine(ObjectIdentifier(type))
    }
  }

  public static func ==(left: InjectIdentity, right: InjectIdentity)-> Bool {
    left.hashValue == right.hashValue
  }
}

extension InjectIdentity {
    public static func of(type: Value.Type? = nil,
                          key: String? = nil,
                          isPrototype: Bool = false,
                          typeToAutoCreate: AnyClass? = nil) -> InjectIdentity {
        .init(type: type, key: key, isPrototype: isPrototype, typeToAutoCreate: typeToAutoCreate)
    }

  public static func register<C>(instanceType: C.Type,
                                 valueType: Value.Type? = nil,
                                 key: String? = nil,
                                 isPrototype: Bool = false) -> InjectIdentity {
    let className = String(reflecting: instanceType.self)
    let instance: AnyClass? = NSClassFromString(className)
    return .of(type: valueType, key: key, isPrototype: isPrototype, typeToAutoCreate: instance)
  }
}

extension InjectIdentity {
  func asNSString() -> NSString {
    return String(describing: self.hashValue) as NSString
  }
}

/// A simple identity that is used for resolution of beans. A `ResolvableIdentity` can easily be converted to a `InjectIdentity` by
/// passing along it's `type` and `key`. Since those are the only properties used to hash the `InjectIdentity`
public struct ResolvableIdentity<Value> {

  public let type: Value.Type?
  public let key: String?

  public init(type: Value.Type? = nil, key: String? = nil) {
    self.type = type
    self.key = key
  }

  func toIdentity()-> InjectIdentity<Value> {
    return .of(type: type, key: key)
  }

  public static func of(type: Value.Type? = nil,
                        key: String? = nil) -> InjectIdentity<Value> {
    ResolvableIdentity(type: type, key: key).toIdentity()
  }

}
