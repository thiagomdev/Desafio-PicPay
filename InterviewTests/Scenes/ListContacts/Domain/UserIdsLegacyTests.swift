import XCTest
@testable import Interview

final class UserIdsLegacyTests: XCTestCase {
    func test_value_returnsUnderlyingIds() {
        let sut = UserIdsLegacy.legacyIds([10, 11, 12, 13])

        XCTAssertEqual(sut.value, [10, 11, 12, 13], "Should expose the ids wrapped in the legacyIds case")
    }

    func test_value_whenIdsAreEmpty_returnsEmptyArray() {
        let sut = UserIdsLegacy.legacyIds([])

        XCTAssertEqual(sut.value, [], "Should return an empty array when no ids are wrapped")
    }

    func test_value_preservesOrder() {
        let sut = UserIdsLegacy.legacyIds([13, 10, 12, 11])

        XCTAssertEqual(sut.value, [13, 10, 12, 11], "Should preserve the order the ids were wrapped in")
    }
}
