import XCTest
import Interview

final class URLSessionHTTPClientTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }

    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
        super.tearDown()
    }

    func test_execute_performsGETRequestWithGivenURL() async {
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.stub(data: anyData, response: anyHTTPURLResponse, error: nil)

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, self.anyURL)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        _ = try? await makeSut().execute(URLRequest(url: anyURL))

        await fulfillment(of: [exp], timeout: 1.0)
    }

    func test_execute_whenRequestFails_throwsTheUnderlyingError() async {
        URLProtocolStub.stub(data: nil, response: nil, error: anyNSError)

        do {
            _ = try await makeSut().execute(URLRequest(url: anyURL))
            XCTFail("Expected execute to throw")
        } catch {
            let receivedError = error as NSError
            XCTAssertEqual(receivedError.domain, anyNSError.domain, "Should propagate the underlying error's domain")
            XCTAssertEqual(receivedError.code, anyNSError.code, "Should propagate the underlying error's code")
        }
    }

    func test_execute_onSuccessWithHTTPURLResponse_deliversDataAndResponse() async throws {
        let response = anyHTTPURLResponse
        URLProtocolStub.stub(data: anyData, response: anyHTTPURLResponse, error: nil)

        let result = try await makeSut().execute(URLRequest(url: anyURL))

        switch result {
        case let .success(receivedData, receivedResponse):
            XCTAssertEqual(receivedData, anyData, "Should deliver the data returned by the session")
            XCTAssertEqual(receivedResponse.url, response.url, "Should deliver the response returned by the session")
            XCTAssertEqual(receivedResponse.statusCode, response.statusCode, "Should deliver the response returned by the session")
        case .failure:
            XCTFail("Expected success, got failure instead")
        }
    }

    func test_execute_whenResponseIsNotHTTP_deliversInvalidDataFailure() async throws {
        URLProtocolStub.stub(data: anyData, response: nonHTTPURLResponse(), error: nil)

        let result = try await makeSut().execute(URLRequest(url: anyURL))

        switch result {
        case .success:
            XCTFail("Expected failure, got success instead")
        case let .failure(error):
            XCTAssertEqual(error, .invalidData, "Should map a non-HTTP response into an invalidData failure")
        }
    }
}

extension URLSessionHTTPClientTests {
    private func makeSut(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(for: sut, file: file, line: line)
        return sut
    }

    private var anyURL: URL {
        URL(string: "https://any-url.com")!
    }

    private var anyData: Data {
        Data("any data".utf8)
    }

    private var anyNSError: NSError {
        NSError(domain: "any error", code: 1)
    }

    private var anyHTTPURLResponse: HTTPURLResponse {
        HTTPURLResponse(url: anyURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    fileprivate final class URLProtocolStub: URLProtocol {
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Swift.Error?
        }

        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        static func stub(data: Data?, response: URLResponse?, error: Swift.Error?) {
            stub = Stub(data: data, response: response, error: error)
        }

        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }

        override class func canInit(with request: URLRequest) -> Bool { true }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

        override func startLoading() {
            if let requestObserver = URLProtocolStub.requestObserver {
                requestObserver(request)
            }

            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
        }

        override func stopLoading() {}
    }
}
