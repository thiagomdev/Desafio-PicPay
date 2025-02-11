import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
        
    public func perform(
        _ request: URLRequest,
        completion: @escaping (HTTPClientResult) -> Void) {
            
        session.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(.failure(Error.invalidURL))
            } else if let data = data,
                let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(Error.invalidData))
            }
        }.resume()
    }
}
