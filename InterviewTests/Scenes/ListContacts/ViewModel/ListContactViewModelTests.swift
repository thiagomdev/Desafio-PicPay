import XCTest
import Interview

final class ListContactViewModelTests: XCTestCase {
    func test_displayMovies_whenServiceSucceeds_returnsAllMappedContacts() async throws {
        let (sut, doubles) = makeSut()
        let contacts: [Contact] = [
            .fixture(id: 0, name: "Shakira"),
            .fixture(id: 1, name: "Ana")
        ]
        doubles.viewModelSpy.expected = .success(contacts)

        let result = try await sut.displayMovies()

        XCTAssertTrue(doubles.viewModelSpy.loadMoviesCalled, "Should call the service to load contacts")
        XCTAssertEqual(doubles.viewModelSpy.loadMoviesCount, 1, "Should call the service exactly once")
        expect(result, toEqual: .success(contacts))
    }

    func test_displayMovies_whenServiceSucceedsWithEmptyList_returnsEmptyContacts() async throws {
        let (sut, doubles) = makeSut()
        doubles.viewModelSpy.expected = .success([])

        let result = try await sut.displayMovies()

        expect(result, toEqual: .success([]))
    }

    func test_displayMovies_whenServiceFails_returnsUnderlyingError() async throws {
        let (sut, doubles) = makeSut()
        doubles.viewModelSpy.expected = .failure(.invalidData)

        let result = try await sut.displayMovies()

        XCTAssertEqual(doubles.viewModelSpy.loadMoviesCount, 1, "Should call the service exactly once")
        expect(result, toEqual: .failure(.invalidData))
    }

    func test_displayMovies_whenCalledTwice_callsServiceTwice() async throws {
        let (sut, doubles) = makeSut()
        doubles.viewModelSpy.expected = .success([])

        _ = try await sut.displayMovies()
        _ = try await sut.displayMovies()

        XCTAssertEqual(doubles.viewModelSpy.loadMoviesCount, 2, "Should call the service once per invocation")
    }

    // MARK: - isLegacy

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

    func test_isLegacy_forEveryLegacyId_notifiesDelegateAsLegacy() {
        let legacyIds = [10, 11, 12, 13]

        for id in legacyIds {
            var (sut, doubles) = makeSut()
            sut.model.append(contentsOf: [.fixture(id: id, name: "Contact \(id)")])

            sut.isLegacy(index: IndexPath(row: 0, section: 0))

            XCTAssertTrue(doubles.delegateSpy.isLegacyCalled, "Should notify legacy for id \(id)")
            XCTAssertEqual(doubles.delegateSpy.expectedName, "Contact \(id)", "Should pass the correct contact name for id \(id)")
        }
    }

    func test_isLegacy_forIdsAdjacentToLegacyRange_notifiesDelegateAsNotLegacy() {
        let nonLegacyIds = [9, 14]

        for id in nonLegacyIds {
            var (sut, doubles) = makeSut()
            sut.model.append(contentsOf: [.fixture(id: id, name: "Contact \(id)")])

            sut.isLegacy(index: IndexPath(row: 0, section: 0))

            XCTAssertTrue(doubles.delegateSpy.notNotLegacy, "Should notify not legacy for id \(id) which sits just outside the legacy range")
            XCTAssertEqual(doubles.delegateSpy.notNotLegacyName, "Contact \(id)", "Should pass the correct contact name for id \(id)")
        }
    }

    func test_isLegacy_whenModelIsEmpty_notifiesDelegateWithDefaultValues() {
        let (sut, doubles) = makeSut()

        sut.isLegacy(index: IndexPath(row: 0, section: 0))

        XCTAssertTrue(doubles.delegateSpy.notNotLegacy, "Should notify delegate as not legacy when there is no contact for the given index")
        XCTAssertEqual(doubles.delegateSpy.notNotLegacyCount, 1, "Should notify delegate exactly once")
        XCTAssertEqual(doubles.delegateSpy.notNotLegacyName, "", "Should pass an empty name when no contact is found")
    }

    func test_isLegacy_whenIndexIsOutOfBounds_notifiesDelegateWithDefaultValues() {
        var (sut, doubles) = makeSut()
        sut.model.append(contentsOf: [.fixture(id: 10, name: "Shakira")])

        sut.isLegacy(index: IndexPath(row: 5, section: 0))

        XCTAssertTrue(doubles.delegateSpy.notNotLegacy, "Should notify delegate as not legacy when the index is out of bounds")
        XCTAssertEqual(doubles.delegateSpy.notNotLegacyCount, 1, "Should notify delegate exactly once")
        XCTAssertEqual(doubles.delegateSpy.notNotLegacyName, "", "Should pass an empty name when the index is out of bounds")
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

    func test_model_whenSetDirectly_replacesExistingContacts() {
        var (sut, _) = makeSut()
        sut.model = [.fixture(id: 0, name: "Zé")]

        sut.model = [.fixture(id: 1, name: "Ana")]

        XCTAssertEqual(sut.model.count, 1, "Should replace the previous contacts instead of appending")
        XCTAssertEqual(sut.model.first?.name, "Ana", "Should keep only the most recently assigned contact")
    }

    func test_setDelegate_whenAssigned_isReturnedByGetter() {
        let (sut, doubles) = makeSut()

        XCTAssertTrue(sut.setDelegate === doubles.delegateSpy, "Should return the delegate that was assigned")
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

    private func expect(
        _ result: ContactResult?,
        toEqual expected: ContactResult,
        file: StaticString = #file,
        line: UInt = #line) {
        guard let result else {
            XCTFail("Expected \(expected), got nil instead", file: file, line: line)
            return
        }

        switch (result, expected) {
        case let (.success(received), .success(expectedItems)):
            XCTAssertEqual(received, expectedItems, file: file, line: line)
        case let (.failure(received), .failure(expectedError)):
            XCTAssertEqual(received, expectedError, file: file, line: line)
        default:
            XCTFail("Expected \(expected), got \(result) instead", file: file, line: line)
        }
    }
}
