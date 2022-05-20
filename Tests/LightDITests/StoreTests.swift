//
//  File.swift


import Foundation
import XCTest
import LightDI

class DIStoreTests: XCTestCase {
  func test_addingResolverDoesNotAddResolved() {
    let store = createStore()
    store.putResolver(StoreIdentities.identityOne) { _ in }
    XCTAssertEqual(store.resolversCount, 1, "Expected only one resolver to be available in store")
    XCTAssertEqual(store.resolvedCount, 0, "Did not expect a resolved object to be added when a resolver is registered")
  }

  func test_shouldReteriveResolverAfterAdding() {
    let store = createStore()
    store.putResolver(StoreIdentities.identityOne) { _ in }
    let value = store.getResolver(StoreIdentities.identityOne)

    XCTAssertNotNil(value, "Expected a value to be returned from store after resolver has been registered")

    let unRegisteredValue = store.getResolver(StoreIdentities.identityTwo)
    XCTAssertNil(unRegisteredValue, "A resolver not registered by an identity should not be retreivable")

    let differentIdentity: InjectIdentity<Int> = .of(key: "firstInteger")
    let value2 = store.getResolver(differentIdentity)
    XCTAssertNotNil(value2, "A new instance of an identity that matches that of" +
                    "the one used in registration should be able to fetch the associated resolver")
  }

  func createStore()-> InjectorStore {
    let store = DefaultInjectorStore()
    return store
  }
}

fileprivate protocol SampleProtocol {
  func performWrite()
}

fileprivate enum StoreIdentities {
  static var identityOne: InjectIdentity<Int> {.of(key: "firstInteger")}
  static var identityTwo: InjectIdentity<String> {.of(key: "firstString")}
  static var identityThree: InjectIdentity<SampleProtocol>{.of(type: SampleProtocol.self)}
}
