import XCTest
import Interview

final class ListContactViewModelTests: XCTestCase {
    func test_loadContacts_success() {
        let (sut, viewModelSpy, _) = makeSut()
        var expectedContact: [Contact] = []
        let contact: [Contact] = [.fixture(id: 0, name: "Shakira")]
        
        viewModelSpy.expected = .success(contact)
        
        sut.displayMovies { success in
            if case let .success(contact) = success {
                expectedContact = contact
            }
        }
        
        XCTAssertNotNil(expectedContact)
        XCTAssertEqual(contact.first?.name, "Shakira")
        XCTAssertEqual(contact.first?.id, 0)
    }
    
    func test_loadContacts_failure() {
        let (sut, viewModelSpy, _) = makeSut()
        let failure: NSError = .init(domain: "some_error", code: -999)
        var expectedError = failure as? Error ?? .invalidData
        
        viewModelSpy.expected = .failure(expectedError)
        
        sut.displayMovies { failure in
            if case let .failure(failure) = failure {
                expectedError = failure
            }
        }
        
        XCTAssertNotNil(expectedError)
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
            .fixture(
                id: 0,
                name: "Zé"
            ),
            .fixture(
                id: 1,
                name: "Ana"
            )
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
        delegateSpy: DelegateSpy) {
            
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
        private(set) var messages = [(contact: [Contact], completion: (HTTPClientResult) -> Void)]()
        var expected: (ContactResult)?
        
        func loadMovies(callback: @escaping (ContactResult) -> Void) {
            if let expected {
                callback(expected)
            }
        }
    }
    
    private func trackForMemoryLeaks(
        for instance: AnyObject,
        file: StaticString = #file,
        line: UInt = #line) {
            
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance,
                "Instance should have been deallocated. Potential memory leak.",
                file: file,
                line: line
            )
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
