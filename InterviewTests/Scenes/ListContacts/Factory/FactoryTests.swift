import XCTest
import UIKit
@testable import Interview

final class FactoryTests: XCTestCase {
    func test_make_returnsAListContactsViewController() {
        let sut = Factory.make()

        XCTAssertTrue(sut is ListContactsViewController, "Should build the contacts list screen as the entry point")
    }

    func test_make_eachCall_returnsANewInstance() {
        let first = Factory.make()
        let second = Factory.make()

        XCTAssertFalse(first === second, "Should create a fresh view controller instance on every call")
    }
}
