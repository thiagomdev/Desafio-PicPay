import XCTest
import Interview

final class ListContactViewModelTests: XCTestCase {
    func test_loadContacts_success() async throws {
        let (sut, viewModelSpy, _) = makeSut()
        let contact: [Contact] = [.fixture(id: 0, name: "Shakira")]
        viewModelSpy.expected = .success(contact)

        let result = try await sut.displayMovies()

        if case let .success(contacts) = result {
            XCTAssertEqual(contacts.first?.name, "Shakira")
            XCTAssertEqual(contacts.first?.id, 0)
        } else {
            XCTFail("Expected success result")
        }
    }

    func test_loadContacts_failure() async throws {
        let (sut, viewModelSpy, _) = makeSut()
        viewModelSpy.expected = .failure(.invalidData)

        let result = try await sut.displayMovies()

        if case .failure = result {
            // correctly returned a failure
        } else {
            XCTFail("Expected failure result")
        }
    }

    func test_is_not_legacy() {
        let (sut, _, delegateSpy) = makeSut()
        delegateSpy.notNotLegacyName = "Shakira"

        sut.isLegacy(index: IndexPath(row: 0, section: 0))

        XCTAssertTrue(delegateSpy.notNotLegacy)
    }

    func test_model() {
        let (sut, _, _) = makeSut()

        let contacts: [Contact] = [
            .fixture(id: 0, name: "Zé"),
            .fixture(id: 1, name: "Ana")
        ]

        sut.model.insert(contacts)

        XCTAssertEqual(sut.model.first?.count, 2)
        XCTAssertEqual(sut.model.first?[0].name, "Zé")
        XCTAssertEqual(sut.model.first?[1].name, "Ana")
        XCTAssertEqual(sut.model.first?[0].id, 0)
        XCTAssertEqual(sut.model.first?[1].id, 1)
    }
}

extension ListContactViewModelTests {
    private func makeSut(file: StaticString = #file, line: UInt = #line) -> (
        sut: ListContactsViewModel,
        viewModelSpy: ListContactViewModelSpy,
        delegateSpy: DelegateSpy
    ) {
        let viewModelSpy = ListContactViewModelSpy()
        let delegateSpy = DelegateSpy()
        let sut = ListContactsViewModel(service: viewModelSpy)
        sut.setDelegate = delegateSpy

        trackForMemoryLeaks(for: sut, file: file, line: line)
        trackForMemoryLeaks(for: viewModelSpy, file: file, line: line)
        trackForMemoryLeaks(for: delegateSpy, file: file, line: line)

        return (sut, viewModelSpy, delegateSpy)
    }

    private final class ListContactViewModelSpy: ListcontactResultLoader {
        var expected: ContactResult?

        func loadMovies() async throws -> ContactResult {
            return expected ?? .failure(.invalidData)
        }
    }
}

final class DelegateSpy: ViewModelDelegate {
    var isLegacyCalled: Bool = false
    var notNotLegacy: Bool = false

    var expectedName: String?
    var notNotLegacyName: String?

    func isLegacy(name: String) {
        expectedName = name
        isLegacyCalled = true
    }

    func notNotLegacy(name: String) {
        notNotLegacyName = name
        notNotLegacy = true
    }
}
