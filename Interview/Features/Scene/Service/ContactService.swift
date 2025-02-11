import Foundation

public enum ContactResult {
    case success([Contact])
    case failure(Error)
}

public protocol ListcontactResultLoader {
    func loadMovies(callback: @escaping (ContactResult) -> Void)
}

public final class ContactService {
    private let apiURL = "https://669ff1b9b132e2c136ffa741.mockapi.io/picpay/ios/interview/contacts"
    
    private let client: HTTPClient

    public typealias Result = ContactResult
    
    public init(client: HTTPClient) {
        self.client = client
    }
}

extension ContactService: ListcontactResultLoader {
    public func loadMovies(callback: @escaping (Result) -> Void) {
        if let url = URL(string: apiURL) {
            let request = URLRequest(url: url)
            client.perform(request) { result in
                switch result {
                case let .success(data, urlResponse):
                    callback(ContactMapper.map(data, from: urlResponse))
                case let .failure(error):
                    callback(.failure(error))
                }
            }
        }
    }
}

public enum ContactMapper {
    private static var OK_200: Int { 200 }

    internal static func map(
        _ data: Data,
        from response: HTTPURLResponse) -> ContactService.Result {
            
        guard response.statusCode == OK_200,
              let contact = try? JSONDecoder().decode([Contact].self, from: data) else {
            return .failure(Error.invalidResponse)
        }
        return .success(contact)
    }
}
