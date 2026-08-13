import Foundation

public enum ContactResult {
    case success([Contact])
    case failure(Error)
}

public protocol ListcontactResultLoader {
    func loadMovies() async throws -> ContactResult
}

public final class ContactService {
    private let apiURL: String
    private let client: HTTPClient

    public typealias Result = ContactResult

    public init(
        client: HTTPClient,
        url: String = "https://669ff1b9b132e2c136ffa741.mockapi.io/picpay/ios/interview/contacts"
    ) {
        self.client = client
        self.apiURL = url
    }
}

extension ContactService: ListcontactResultLoader {
    public func loadMovies() async throws -> ContactResult {
        if let url = URL(string: apiURL) {
            let request = URLRequest(url: url)
            let result = try await client.execute(request)
            switch result {
            case let .success(data, response):
                return try ContactMapper.map(data, from: response)
            case let .failure(error):
                throw error
            }
        }
        return .failure(.invalidData)
    }
}

public enum ContactMapper {
    private static var OK_200: Int { 200 }

    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> ContactService.Result {
        guard response.statusCode == OK_200 else {
            return .failure(.invalidResponse)
        }
        do {
            let decodedData = try JSONDecoder().decode([Contact].self, from: data)
            return .success(decodedData)
        } catch {
            return .failure(.invalidData)
        }
    }
}
