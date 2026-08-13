import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func execute(_ request: URLRequest) async throws -> HTTPClientResult {
        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse {
            return .success(data, response)
        } else {
            return .failure(.invalidData)
        }
    }
}
