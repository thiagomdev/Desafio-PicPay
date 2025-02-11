import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func perform(_ request: URLRequest, completion: @escaping (HTTPClientResult) -> Void)
}
