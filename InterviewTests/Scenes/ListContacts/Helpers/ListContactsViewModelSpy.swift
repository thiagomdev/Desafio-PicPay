import Foundation
import Interview

final class ListContactsViewModelSpy: ListContactsViewModelProtocol {
    var model: [Contact] = []
    weak var setDelegate: ViewModelDelegate?
    var displayMoviesResult: ContactResult?

    private(set) var isLegacyCallCount = 0
    private(set) var isLegacyIndexPath: IndexPath?
    private(set) var displayMoviesCallCount = 0

    func isLegacy(index: IndexPath) {
        isLegacyCallCount += 1
        isLegacyIndexPath = index
    }

    func displayMovies() async throws -> ContactResult? {
        displayMoviesCallCount += 1
        return displayMoviesResult
    }
}
