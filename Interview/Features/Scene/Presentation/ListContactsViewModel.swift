import Foundation

public enum Error: Swift.Error {
    case invalidData
    case invalidResponse
    case invalidURL
}

public protocol ListContactsViewModelProtocol {
    var model: Set<[Contact]> { get set }
    func isLegacy(index: IndexPath)
    var setDelegate: ViewModelDelegate? { get set }
    func displayMovies() async throws -> ContactResult?
}

public protocol ViewModelDelegate: AnyObject {
    func isLegacy(name: String)
    func notNotLegacy(name: String)
}

public final class ListContactsViewModel {
    private var legacy: UserIdsLegacy?
    private let service: ListcontactResultLoader
    private var dataObject = Set<[Contact]>()
    
    private weak var delegate: ViewModelDelegate?
    
    public init(service: ListcontactResultLoader) {
        self.service = service
    }
}

extension ListContactsViewModel: ListContactsViewModelProtocol {
    public var setDelegate: ViewModelDelegate? {
        get { delegate }
        set { delegate = newValue }
    }
    
    public var model: Set<[Contact]> {
        get { dataObject }
        set { dataObject = newValue }
    }
    
    public func isLegacy(index: IndexPath) {
        getContactInformation(basedOn: index)
    }
    
    public func displayMovies() async throws -> ContactResult? {
        try await service.loadMovies()
    }
    
    private func getContactInformation(basedOn contact: IndexPath) {
        legacy = UserIdsLegacy.legacyIds([10, 11, 12, 13])

        if legacy?.value.contains(where: { $0 == didTapIndex(contact).id }) ?? false {
            delegate?.isLegacy(name: didTapIndex(contact).name)
        } else {
            delegate?.notNotLegacy(name: didTapIndex(contact).name)
        }
    }
    
    private func didTapIndex(_ index: IndexPath) -> (id: Int, name: String) {
        if let id = dataObject.first?[index.row].id,
           let name = dataObject.first?[index.row].name {
            return (id, name)
        }
        return (.zero, String())
    }
}
