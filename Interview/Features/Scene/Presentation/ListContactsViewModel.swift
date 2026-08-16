import Foundation

public enum Error: Swift.Error {
    case invalidData
    case invalidResponse
    case invalidURL
}

public protocol ListContactsViewModelProtocol {
    var model: [Contact] { get set }
    func isLegacy(index: IndexPath)
    var setDelegate: ViewModelDelegate? { get set }
    func displayMovies() async throws -> ContactResult?
}

public protocol ViewModelDelegate: AnyObject {
    func isLegacy(name: String)
    func notNotLegacy(name: String)
}

public actor ListContactsViewModel {
    private var legacy: UserIdsLegacy?
    private let service: ListcontactResultLoader
    private var dataObject = [Contact]()
    
    private weak var delegate: ViewModelDelegate?
    
    public init(service: ListcontactResultLoader) {
        self.service = service
    }
}

extension ListContactsViewModel: @preconcurrency ListContactsViewModelProtocol {
    public var setDelegate: ViewModelDelegate? {
        get { delegate }
        set { delegate = newValue }
    }
    
    public var model: [Contact] {
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
        guard dataObject.indices.contains(index.row) else {
            return (.zero, String())
        }
        let contact = dataObject[index.row]
        return (contact.id, contact.name)
    }
}
