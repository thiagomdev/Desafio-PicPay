import UIKit

public enum Factory {
    static func make() -> UIViewController {
        let service = ContactService(client: URLSessionHTTPClient())
        let viewModel = ListContactsViewModel(service: service)
        let viewController = ListContactsViewController(viewModel: viewModel)
        return viewController
    }
}
