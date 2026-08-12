import XCTest
import Interview
import Testing

final class ListContactServiceTests: XCTestCase {
    func test_init_does_not_request_data_from_URL() {
        let  (_, mock) = makeSut()

        XCTAssertTrue(mock.requestedURLs.isEmpty)
    }
    
    func test_load_requests_data_from_URL() {
        let (sut, mock) = makeSut()
        
        sut.loadMovies { _ in }
        
        XCTAssertEqual(mock.requestedURLs, [anyURL])
    }
    
    func test_load_twice_requests_data_from_URLTwice() {
        let (sut, mock) = makeSut()
        
        sut.loadMovies { _ in }
        sut.loadMovies { _ in }
        
        XCTAssertEqual(mock.requestedURLs, [anyURL, anyURL])
    }
    
    func test_load_delivers_error_on_client_error() {
        let  (sut, mock) = makeSut()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let clientError = NSError(domain: "Test", code: -999)
            let error = clientError as? Error ?? .invalidData
            mock.complete(with: error)
        })
    }
    
    func test_load_delivers_error_on_Non_200_HTTPResponse() {
        let  (sut, mock) = makeSut()
        let samples = [199, 201, 300, 400, 500].enumerated()
        
        samples.forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidResponse), when: {
                let json = makeItemsJSON([])
                mock.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_delivers_error_on_200HTTPResponse_with_invalidJSON() {
        let  (sut, mock) = makeSut()
        
        expect(sut, toCompleteWith: failure(.invalidResponse), when: {
            let invalidJSON: Data = .init(_: "invalid json".utf8)
            mock.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_delivers_no_items_on_200HTTPResponse_with_empty_json_list() {
        let  (sut, mock) = makeSut()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyJSON = makeItemsJSON([])
            mock.complete(withStatusCode: 200, data: emptyJSON)
        })
    }

    func test_load_delivers_contacts_on_200HTTPResponse_with_json_items() {
        let  (sut, mock) = makeSut()
        let item1 = makeItem(id: 1, name: "a name", photoURL: "https://a-url.com")
        let item2 = makeItem(id: 2, name: "another name", photoURL: "https://another-url.com")

        expect(sut, toCompleteWith: .success([item1.model, item2.model]), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            mock.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_does_not_deliver_result_after_SUT_instance_has_been_deallocated() {
        let (sut, mock) = makeSut()

        var capturedResults = [ContactService.Result]()
        sut.loadMovies { capturedResults.append($0) }

        mock.complete(withStatusCode: 200, data: makeItemsJSON([]))

        XCTAssertFalse(capturedResults.isEmpty)
    }
}

extension ListContactServiceTests {
    private func makeSut(
        file: StaticString = #file,
        line: UInt = #line) -> (sut: ContactService, mock: HTTPClientMock) {
        let mock = HTTPClientMock()
        let sut = ContactService(client: mock)
            
        trackForMemoryLeaks(for: sut, file: file, line: line)
        trackForMemoryLeaks(for: mock, file: file, line: line)
            
        return (sut, mock)
    }
    
    private func expect(
        _ sut: ContactService,
        toCompleteWith expectedResult: ContactService.Result,
        when execute: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Wai for load completion")
            
        sut.loadMovies { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedIError as NSError), .failure(expectedIError as NSError)):
                XCTAssertEqual(receivedIError, expectedIError, file: file, line: line)
            default:
                XCTFail("Expected result \(receivedResult) got \(expectedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
            
        execute()
            
        waitForExpectations(timeout: 1.0)
    }
    
    private func failure(_ error: Error) -> ContactService.Result {
        return .failure(error)
    }
 
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: items)
    }
    
    private final class HTTPClientMock: HTTPClient {
        private(set) var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] { messages.map { $0.url } }
        
        func perform(_ request: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((request.url!, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
    
    private func makeItem(
        id: Int,
        name: String,
        photoURL: String) -> (model: Contact, json: [String: Any]) {
            
            let item = Contact(
                id: id,
                name: name,
                photoURL: photoURL
            )
            
        let json = [
            "id": id,
            "name": name,
            "photoURL": photoURL
        ].compactMapValues { $0 }
    
        return (item, json)
    }
    
    private var anyURL: URL {
        URL(string: "https://669ff1b9b132e2c136ffa741.mockapi.io/picpay/ios/interview/contacts")!
    }
}
