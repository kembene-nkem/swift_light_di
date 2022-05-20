//
//  File.swift


import Foundation

public class DIContainer: LightInjector {
  public static var shared: DIContainer?
  public override init(store: InjectorStore? = nil) {
    super.init(store: store ?? DefaultInjectorStore())
  }
}

/**
 Resolves and/or registers this bean
 */
@propertyWrapper
public struct Inject<Value> {
  private var container: Resolvable?
  private let identity: InjectIdentity<Value>

  public lazy var wrappedValue: Value = {
    do {
      guard let container = self.container else {
        throw ResolvableError
          .dependencyNotFound(identity: .fromIdentity(identity: identity), friendlyMessage: "DI Container not specified", cause: nil)
      }
      let value = try container.resolveValue(identity)
      self.container = nil
      return value
    } catch {
      container = nil
      fatalError(error.localizedDescription)
    }
  }()

  public init(_ identity: ResolvableIdentity<Value>, container: Injectable? = nil) {
    self.container = container
    self.identity = identity.toIdentity()
  }

  public init(type: Value.Type? = nil, key: String? = nil, container: Injectable? = nil) {
    self.identity = ResolvableIdentity.of(type: type, key: key)
    self.container = container
  }
}

@propertyWrapper
public struct InjectSafe<Value> {
  private var container: Resolvable?
  private let identity: InjectIdentity<Value>

  public lazy var wrappedValue: Value? = {
    let value = try? container?.resolveValue(identity)
    container = nil
    return value
  }()

  public init(_ identity: ResolvableIdentity<Value>, container: Injectable? = nil) {
    self.container = container
    self.identity = identity.toIdentity()
  }

  public init(type: Value.Type? = nil, key: String? = nil, container: Injectable? = nil) {
    self.identity = ResolvableIdentity.of(type: type, key: key)
    self.container = container
  }

  public init(register: InjectIdentity<Value>,
              value: Value? = nil,
              resolver: Resolver<Value>? = nil,
              container: Injectable? = nil) {
    self.container = container
    self.identity = register
    if let value {
      container?.register(identity, value)
    } else if let resolver {
      container?.register(identity, resolver)
    }
    else {
      container?.register(identity, instanceClass: Value.self)
    }
  }

  public init<Instance>(register: InjectIdentity<Value>,
              instanceType: Instance.Type,
              container: Injectable? = nil) {
    self.container = container
    self.identity = register
    container?.register(identity, instanceClass: instanceType.self)
  }

  public init(aliasIdentity: InjectIdentity<Value>,
              referenceIdentity: InjectIdentity<Value>,
                        container: Injectable? = nil) {
    self.container = container
    self.identity = aliasIdentity
    container?.registerAlias(identity, reference: referenceIdentity)
  }
}

/**
 This property wrapper is used to register a bean into the specified container. Note that this only does registration and it would not in any way resolve the bean. For example

     class Manager {
      @RegisterBean
      var beanRegistration: Car?
     }
     let manager = Manager()
     print(manager.beanRegistration) /// this value will always be nil, because the @RegisterBean property provider does not in any way try to resolve the bean

 - Note: Properties annotated with `RegisterBean` wrapper must always be declared as Optionals
 */
@propertyWrapper
public struct RegisterBean<Value> {

  public lazy var wrappedValue: Value? = {
    nil
  }()

  /// Register this bean such that an instance of ``instanceType`` will be created during resolution
  public init<Instance>(_ instanceType: Instance.Type,
                 key: String? = nil,
                 isPrototype: Bool = false,
                 container: Injectable? = nil) {
    let identity: InjectIdentity<Value> = .register(instanceType: instanceType, valueType: Value.self, key: key, isPrototype: isPrototype)
    let registerContainer = container ?? DIContainer.shared
    /// Since the InjectIdentity already specifies the instance type to create, it's save to pass Void.self as the instance type to the register method
    registerContainer?.register(identity, instanceClass: Void.self)
  }

  /// Register this as an alias that points to another bean identified by ``referenceIdentity``
  public init<Reference>(referenceIdentity: InjectIdentity<Reference>, key: String? = nil, isPrototype: Bool = false, container: Injectable? = nil) {
    let registerContainer = container ?? DIContainer.shared
    let identity: InjectIdentity<Value> = .of(type: Value.self, key: key, isPrototype: isPrototype)
    registerContainer?.registerAlias(identity, reference: referenceIdentity)
  }

  public init(key: String? = nil,
              isPrototype: Bool = false,
              value: Value? = nil,
              resolver: Resolver<Value>? = nil,
              container: Injectable? = nil) {
    let registerContainer = container ?? DIContainer.shared
    let identity: InjectIdentity<Value> = .of(type: Value.self, key: key, isPrototype: isPrototype)
    if let value {
      registerContainer?.register(identity, value)
    } else if let resolver {
      registerContainer?.register(identity, resolver)
    }
    else {
      registerContainer?.register(identity, instanceClass: Value.self)
    }
  }
}
