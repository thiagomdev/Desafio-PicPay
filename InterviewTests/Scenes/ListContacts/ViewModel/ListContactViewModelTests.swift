import XCTest
import Interview

final class ListContactViewModelTests: XCTestCase {
    func test_displayMovies_whenServiceSucceeds_returnsContacts() async throws {
        let (sut, doubles) = makeSut()
        let contact: [Contact] = [.fixture(id: 0, name: "Shakira")]
        doubles.viewModelSpy.expected = .success(contact)

        let result = try await sut.displayMovies()

        if case let .success(contacts) = result {
            XCTAssertTrue(doubles.viewModelSpy.loadMoviesCalled, "Should call the service to load contacts")
            XCTAssertEqual(doubles.viewModelSpy.loadMoviesCount, 1, "Should call the service exactly once")
            XCTAssertEqual(contacts.first?.name, "Shakira", "Should return the contact name from the service")
            XCTAssertEqual(contacts.first?.id, 0, "Should return the contact id from the service")
        } else {
            XCTFail("Expected success result")
        }
    }

    func test_displayMovies_whenServiceFails_returnsFailure() async throws {
        let (sut, doubles) = makeSut()
        doubles.viewModelSpy.expected = .failure(.invalidData)

        let result = try await sut.displayMovies()

        if case .failure = result {
            // correctly returned a failure
        } else {
            XCTFail("Expected failure result")
        }
    }

    func test_isLegacy_whenContactIsNotInLegacyList_notifiesDelegateAsNotLegacy() {
        var (sut, doubles) = makeSut()
        let contact: [Contact] = [.fixture(id: 2, name: "Ana")]
        sut.model.append(contentsOf: contact)

        sut.isLegacy(index: IndexPath(row: 0, section: 0))

        XCTAssertTrue(doubles.delegateSpy.notNotLegacy, "Should notify delegate that the contact is not legacy")
        XCTAssertEqual(doubles.delegateSpy.notNotLegacyCount, 1, "Should notify delegate exactly once")
        XCTAssertEqual(doubles.delegateSpy.notNotLegacyName, "Ana", "Should pass the correct contact name to the delegate")
    }

    func test_isLegacy_whenContactIsInLegacyList_notifiesDelegateAsLegacy() {
        var (sut, doubles) = makeSut()
        let contact: [Contact] = [.fixture(id: 10, name: "Shakira")]
        sut.model.append(contentsOf: contact)

        sut.isLegacy(index: IndexPath(row: 0, section: 0))

        XCTAssertTrue(doubles.delegateSpy.isLegacyCalled, "Should notify delegate that the contact is legacy")
        XCTAssertEqual(doubles.delegateSpy.isLegacyCount, 1, "Should notify delegate exactly once")
        XCTAssertEqual(doubles.delegateSpy.expectedName, "Shakira", "Should pass the correct contact name to the delegate")
    }

    func test_setDelegate_whenAssigned_isReturnedByGetter() {
        let (sut, doubles) = makeSut()

        XCTAssertTrue(sut.setDelegate === doubles.delegateSpy, "Should return the delegate that was assigned")
    }

    func test_isLegacy_whenModelIsEmpty_notifiesDelegateWithDefaultValues() {
        let (sut, doubles) = makeSut()

        sut.isLegacy(index: IndexPath(row: 0, section: 0))

        XCTAssertTrue(doubles.delegateSpy.notNotLegacy, "Should notify delegate as not legacy when there is no contact for the given index")
        XCTAssertEqual(doubles.delegateSpy.notNotLegacyCount, 1, "Should notify delegate exactly once")
        XCTAssertEqual(doubles.delegateSpy.notNotLegacyName, "", "Should pass an empty name when no contact is found")
    }

    func test_model_whenInsertingContacts_storesAllContactsInOrder() {
        var (sut, _) = makeSut()

        let contacts: [Contact] = [
            .fixture(id: 0, name: "Zé"),
            .fixture(id: 1, name: "Ana")
        ]

        sut.model.append(contentsOf: contacts)

        XCTAssertEqual(sut.model.count, 2, "Should insert both contacts into the model")
        XCTAssertEqual(sut.model[0].name, "Zé", "Should keep the first contact's name")
        XCTAssertEqual(sut.model[1].name, "Ana", "Should keep the second contact's name")
        XCTAssertEqual(sut.model[0].id, 0, "Should keep the first contact's id")
        XCTAssertEqual(sut.model[1].id, 1, "Should keep the second contact's id")
    }
}

extension ListContactViewModelTests {
    private typealias Doubles = (viewModelSpy: ListContactViewModelSpy, delegateSpy: DelegateSpy)

    private func makeSut(file: StaticString = #file, line: UInt = #line) -> (
        sut: ListContactsViewModelProtocol, doubles: Doubles) {

        let viewModelSpy = ListContactViewModelSpy()
        let delegateSpy = DelegateSpy()
        let sut = ListContactsViewModel(service: viewModelSpy)
        var protocolSut: ListContactsViewModelProtocol = sut
        protocolSut.setDelegate = delegateSpy

        trackForMemoryLeaks(for: sut, file: file, line: line)
        trackForMemoryLeaks(for: viewModelSpy, file: file, line: line)
        trackForMemoryLeaks(for: delegateSpy, file: file, line: line)

        return (protocolSut, (viewModelSpy, delegateSpy))
    }
}

final class ListContactViewModelSpy: ListcontactResultLoader {
    var expected: ContactResult?

    private(set) var loadMoviesCalled: Bool = false
    private(set) var loadMoviesCount: Int = 0

    func loadMovies() async throws -> ContactResult {
        loadMoviesCalled = true
        loadMoviesCount += 1
        return expected ?? .failure(.invalidData)
    }
}

final class DelegateSpy: ViewModelDelegate {
    private(set) var isLegacyCalled: Bool = false
    private(set) var isLegacyCount: Int = 0
    var expectedName: String?

    private(set) var notNotLegacy: Bool = false
    private(set) var notNotLegacyCount: Int = 0
    var notNotLegacyName: String?

    func isLegacy(name: String) {
        isLegacyCalled = true
        isLegacyCount += 1
        expectedName = name
    }

    func notNotLegacy(name: String) {
        notNotLegacy = true
        notNotLegacyCount += 1
        notNotLegacyName = name
    }
}
