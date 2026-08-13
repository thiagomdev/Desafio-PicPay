import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func execute(_ request: URLRequest) async throws -> HTTPClientResult
}
