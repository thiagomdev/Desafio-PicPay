import XCTest
import Interview

final class ContactTests: XCTestCase {
    func test_decode_fromValidJSON_returnsContact() throws {
        let json = Data("""
        { "id": 1, "name": "Shakira", "photoURL": "https://a-url.com" }
        """.utf8)

        let contact = try JSONDecoder().decode(Contact.self, from: json)

        XCTAssertEqual(contact, Contact(id: 1, name: "Shakira", photoURL: "https://a-url.com"))
    }

    func test_decode_whenRequiredKeyIsMissing_throws() {
        let json = Data("""
        { "id": 1, "name": "Shakira" }
        """.utf8)

        XCTAssertThrowsError(try JSONDecoder().decode(Contact.self, from: json), "Should fail to decode when photoURL is missing")
    }

    func test_equality_whenAllPropertiesMatch_returnsTrue() {
        let lhs = Contact(id: 1, name: "Shakira", photoURL: "https://a-url.com")
        let rhs = Contact(id: 1, name: "Shakira", photoURL: "https://a-url.com")

        XCTAssertEqual(lhs, rhs, "Contacts with identical properties should be equal")
    }

    func test_equality_whenAnyPropertyDiffers_returnsFalse() {
        let base = Contact(id: 1, name: "Shakira", photoURL: "https://a-url.com")

        XCTAssertNotEqual(base, Contact(id: 2, name: "Shakira", photoURL: "https://a-url.com"), "Should differ when the id changes")
        XCTAssertNotEqual(base, Contact(id: 1, name: "Ana", photoURL: "https://a-url.com"), "Should differ when the name changes")
        XCTAssertNotEqual(base, Contact(id: 1, name: "Shakira", photoURL: "https://another-url.com"), "Should differ when the photoURL changes")
    }

    func test_hashValue_whenAllPropertiesMatch_isConsistent() {
        let lhs = Contact(id: 1, name: "Shakira", photoURL: "https://a-url.com")
        let rhs = Contact(id: 1, name: "Shakira", photoURL: "https://a-url.com")

        XCTAssertEqual(lhs.hashValue, rhs.hashValue, "Equal contacts should produce the same hash value")
    }
}
