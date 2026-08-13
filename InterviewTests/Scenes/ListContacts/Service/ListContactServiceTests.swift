import XCTest
import Interview

final class ListContactServiceTests: XCTestCase {
    func test_init_does_not_request_data_from_URL() {
        let (_, mock) = makeSut()

        XCTAssertTrue(mock.requestedURLs.isEmpty)
    }

    func test_load_requests_data_from_URL() async throws {
        let (sut, mock) = makeSut()
        mock.stub(result: .success(makeItemsJSON([]), makeResponse(statusCode: 200)))

        _ = try await sut.loadMovies()

        XCTAssertEqual(mock.requestedURLs, [anyURL])
    }

    func test_load_twice_requests_data_from_URLTwice() async throws {
        let (sut, mock) = makeSut()
        mock.stub(result: .success(makeItemsJSON([]), makeResponse(statusCode: 200)))

        _ = try await sut.loadMovies()
        _ = try await sut.loadMovies()

        XCTAssertEqual(mock.requestedURLs, [anyURL, anyURL])
    }

    func test_load_delivers_error_on_client_error() async {
        let (sut, mock) = makeSut()
        let clientError = NSError(domain: "Test", code: -999)
        mock.stub(error: clientError)

        do {
            _ = try await sut.loadMovies()
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, clientError.domain)
            XCTAssertEqual(error.code, clientError.code)
        }
    }

    func test_load_delivers_error_on_Non_200_HTTPResponse() async throws {
        let (sut, mock) = makeSut()

        for code in [199, 201, 300, 400, 500] {
            mock.stub(result: .success(makeItemsJSON([]), makeResponse(statusCode: code)))
            let result = try await sut.loadMovies()
            expect(result, toEqual: failure(.invalidResponse))
        }
    }

    func test_load_delivers_error_on_200HTTPResponse_with_invalidJSON() async throws {
        let (sut, mock) = makeSut()
        let invalidJSON = Data("invalid json".utf8)
        mock.stub(result: .success(invalidJSON, makeResponse(statusCode: 200)))

        let result = try await sut.loadMovies()

        expect(result, toEqual: failure(.invalidData))
    }

    func test_load_delivers_no_items_on_200HTTPResponse_with_empty_json_list() async throws {
        let (sut, mock) = makeSut()
        mock.stub(result: .success(makeItemsJSON([]), makeResponse(statusCode: 200)))

        let result = try await sut.loadMovies()

        expect(result, toEqual: .success([]))
    }

    func test_load_delivers_contacts_on_200HTTPResponse_with_json_items() async throws {
        let (sut, mock) = makeSut()
        let item1 = makeItem(id: 1, name: "a name", photoURL: "https://a-url.com")
        let item2 = makeItem(id: 2, name: "another name", photoURL: "https://another-url.com")
        mock.stub(result: .success(makeItemsJSON([item1.json, item2.json]), makeResponse(statusCode: 200)))

        let result = try await sut.loadMovies()

        expect(result, toEqual: .success([item1.model, item2.model]))
    }

    func test_load_does_not_deliver_result_after_SUT_instance_has_been_deallocated() async throws {
        let (sut, mock) = makeSut()
        mock.stub(result: .success(makeItemsJSON([]), makeResponse(statusCode: 200)))

        let result = try await sut.loadMovies()

        XCTAssertNotNil(result)
    }

    func test_load_throws_on_client_failure_result() async {
        let (sut, mock) = makeSut()
        mock.stub(result: .failure(.invalidData))

        do {
            _ = try await sut.loadMovies()
            XCTFail("Expected error to be thrown")
        } catch let error as Interview.Error {
            XCTAssertEqual(error, .invalidData)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

extension ListContactServiceTests {
    private func makeSut(
        url: String = "https://669ff1b9b132e2c136ffa741.mockapi.io/picpay/ios/interview/contacts",
        file: StaticString = #file,
        line: UInt = #line) -> (sut: ContactService, mock: HTTPClientMock) {
        let mock = HTTPClientMock()
        let sut = ContactService(client: mock, url: url)

        trackForMemoryLeaks(for: sut, file: file, line: line)
        trackForMemoryLeaks(for: mock, file: file, line: line)

        return (sut, mock)
    }

    private func expect(
        _ result: ContactResult,
        toEqual expected: ContactResult,
        file: StaticString = #file,
        line: UInt = #line) {
        switch (result, expected) {
        case let (.success(received), .success(expectedItems)):
            XCTAssertEqual(received, expectedItems, file: file, line: line)
        case (.failure(let received), .failure(let expected)):
            XCTAssertEqual(received, expected, file: file, line: line)
        default:
            XCTFail("Expected \(expected), got \(result)", file: file, line: line)
        }
    }

    private func failure(_ error: Interview.Error) -> ContactResult {
        return .failure(error)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: items)
    }

    private func makeItem(
        id: Int,
        name: String,
        photoURL: String) -> (model: Contact, json: [String: Any]) {
        let item = Contact(id: id, name: name, photoURL: photoURL)
        let json: [String: Any] = ["id": id, "name": name, "photoURL": photoURL]
        return (item, json)
    }

    private func makeResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    private var anyURL: URL {
        URL(string: "https://669ff1b9b132e2c136ffa741.mockapi.io/picpay/ios/interview/contacts")!
    }

    fileprivate final class HTTPClientMock: HTTPClient {
        private(set) var requestedURLs = [URL]()
        private var stubbedResult: HTTPClientResult?
        private var stubbedError: Swift.Error?

        func stub(result: HTTPClientResult) {
            stubbedResult = result
            stubbedError = nil
        }

        func stub(error: Swift.Error) {
            stubbedError = error
            stubbedResult = nil
        }

        func execute(_ request: URLRequest) async throws -> HTTPClientResult {
            guard let url = request.url else {
                throw NSError(domain: "HTTPClientMock", code: -2, userInfo: [NSLocalizedDescriptionKey: "Request has no URL"])
            }
            requestedURLs.append(url)
            if let error = stubbedError {
                throw error
            }
            guard let result = stubbedResult else {
                throw NSError(domain: "HTTPClientMock", code: -1, userInfo: [NSLocalizedDescriptionKey: "No stub configured"])
            }
            return result
        }
    }
}
