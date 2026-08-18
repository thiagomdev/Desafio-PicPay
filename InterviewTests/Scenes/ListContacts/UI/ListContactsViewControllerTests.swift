import XCTest
import UIKit
@testable import Interview

final class ListContactsViewControllerTests: XCTestCase {
    func test_viewDidLoad_setsTitle() {
        let (sut, _) = makeSut()

        XCTAssertEqual(sut.title, "Lista de Contatos", "Should title the screen for the contacts list")
    }

    func test_viewDidLoad_addsTableViewToViewHierarchy() {
        let (sut, _) = makeSut()

        XCTAssertTrue(sut.view.subviews.contains(sut.tableView), "Should add the table view to the screen")
    }

    func test_viewDidLoad_configuresTableViewDataSourceDelegateAndRowHeight() {
        let (sut, _) = makeSut()

        XCTAssertTrue(sut.tableView.dataSource === sut, "Should be its own table view data source")
        XCTAssertTrue(sut.tableView.delegate === sut, "Should be its own table view delegate")
        XCTAssertEqual(sut.tableView.rowHeight, 120, "Should use a fixed row height")
    }

    func test_viewDidLoad_setsActivityIndicatorAsTableViewBackgroundAndAnimating() {
        let (sut, _) = makeSut()

        XCTAssertTrue(sut.tableView.backgroundView === sut.activity, "Should show the activity indicator behind the table view while loading")
        XCTAssertTrue(sut.activity.isAnimating, "Should start animating the activity indicator")
    }

    func test_viewWillAppear_setsSelfAsViewModelDelegate() {
        let (sut, viewModel) = makeSut()

        XCTAssertTrue(viewModel.setDelegate === sut, "Should register itself as the view model's delegate")
    }

    func test_numberOfRowsInSection_returnsViewModelModelCount() {
        let viewModel = ListContactsViewModelSpy()
        viewModel.model = [.fixture(id: 0, name: "Zé"), .fixture(id: 1, name: "Ana")]
        let (sut, _) = makeSut(viewModel: viewModel)

        let rows = sut.tableView(sut.tableView, numberOfRowsInSection: 0)

        XCTAssertEqual(rows, 2, "Should mirror the view model's contact count")
    }

    func test_cellForRowAt_configuresContactCellWithModel() {
        let viewModel = ListContactsViewModelSpy()
        viewModel.model = [.fixture(id: 0, name: "Shakira")]
        let (sut, _) = makeSut(viewModel: viewModel)

        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))

        XCTAssertTrue(cell is ContactCell, "Should dequeue a ContactCell")
        XCTAssertEqual((cell as? ContactCell)?.fullnameLabel.text, "Shakira", "Should configure the cell with the contact at the given row")
    }

    func test_heightForRowAt_returnsDefaultRowHeight() {
        let (sut, _) = makeSut()

        let height = sut.tableView(sut.tableView, heightForRowAt: IndexPath(row: 0, section: 0))

        XCTAssertEqual(height, 130, "Should use the default height when the table view doesn't have flexible sizing")
    }

    func test_didSelectRowAt_asksViewModelIfContactIsLegacy() {
        let (sut, viewModel) = makeSut()
        let indexPath = IndexPath(row: 2, section: 0)

        sut.tableView(sut.tableView, didSelectRowAt: indexPath)

        XCTAssertEqual(viewModel.isLegacyCallCount, 1, "Should ask the view model to check the selected contact exactly once")
        XCTAssertEqual(viewModel.isLegacyIndexPath, indexPath, "Should pass the selected index path")
    }

    func test_willDisplayCell_animatesTransformBackToIdentity() {
        let (sut, _) = makeSut()
        let cell = UITableViewCell()

        sut.tableView(sut.tableView, willDisplay: cell, forRowAt: IndexPath(row: 0, section: 0))

        XCTAssertEqual(cell.transform, .identity, "UIView.animate's animations closure runs synchronously, so the cell should already carry its final identity transform")
    }

    func test_isLegacyDelegate_presentsAlertWithContactName() {
        let (sut, _, _) = makeSutInWindow()

        sut.isLegacy(name: "Shakira")

        let alert = waitForPresentedAlert(on: sut)
        XCTAssertEqual(alert?.title, "Atenção", "Should title the legacy alert")
        XCTAssertEqual(alert?.message, "Você tocou no contato sorteado, com o nome de Shakira.", "Should mention the legacy contact's name")
    }

    func test_notNotLegacyDelegate_presentsAlertWithContactName() {
        let (sut, _, _) = makeSutInWindow()

        sut.notNotLegacy(name: "Ana")

        let alert = waitForPresentedAlert(on: sut)
        XCTAssertEqual(alert?.title, "Você tocou em", "Should title the non-legacy alert")
        XCTAssertEqual(alert?.message, "Ana", "Should mention the tapped contact's name")
    }

    func test_viewDidLoad_onDisplayMoviesSuccess_appendsContactsAndReloadsTable() {
        let viewModel = ListContactsViewModelSpy()
        viewModel.displayMoviesResult = .success([.fixture(id: 1, name: "Shakira")])
        let (sut, _) = makeSut(viewModel: viewModel)

        let predicate = NSPredicate { _, _ in viewModel.model.count == 1 }
        wait(for: [expectation(for: predicate, evaluatedWith: nil)], timeout: 5.0)

        XCTAssertEqual(viewModel.model.first?.name, "Shakira", "Should append the contacts returned by the service")
        XCTAssertFalse(sut.activity.isAnimating, "Should stop the activity indicator once the contacts are loaded")
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 1, "Should reload the table view with the loaded contacts")
    }

    func test_viewDidLoad_onDisplayMoviesFailure_presentsErrorAlert() {
        let viewModel = ListContactsViewModelSpy()
        viewModel.displayMoviesResult = .failure(.invalidData)
        let (sut, _, _) = makeSutInWindow(viewModel: viewModel)

        let alert = waitForPresentedAlert(on: sut)
        XCTAssertEqual(alert?.title, "Hey you!", "Should present an error alert when loading the contacts fails")
    }
}

extension ListContactsViewControllerTests {
    /// For tests that don't need `present(_:animated:)` to actually take effect.
    /// Deliberately avoids a real `UIWindow`: hosting the controller in one makes
    /// its deallocation unreliable (UIKit's appearance-transition bookkeeping keeps
    /// it alive past a single teardown block), which produced false-positive leak
    /// failures on every test. `loadViewIfNeeded` + a manual appearance transition
    /// still exercises viewDidLoad/viewWillAppear deterministically without that cost.
    private func makeSut(
        viewModel: ListContactsViewModelSpy = ListContactsViewModelSpy(),
        file: StaticString = #file,
        line: UInt = #line) -> (sut: ListContactsViewController, viewModel: ListContactsViewModelSpy) {

        let sut = ListContactsViewController(viewModel: viewModel)
        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()

        waitForLoadData(on: viewModel)

        trackForMemoryLeaks(for: sut, file: file, line: line)
        trackForMemoryLeaks(for: viewModel, file: file, line: line)

        return (sut, viewModel)
    }

    /// For the tests that need `present(_:animated:)` to actually register a
    /// `presentedViewController` — that requires the controller's view to be in a
    /// real window. Not leak-checked: see `makeSut`'s note on why that's unreliable
    /// here. The window is torn down (without asserting dealloc) to keep console
    /// warnings and key-window contention from bleeding into later tests.
    private func makeSutInWindow(
        viewModel: ListContactsViewModelSpy = ListContactsViewModelSpy()
    ) -> (sut: ListContactsViewController, viewModel: ListContactsViewModelSpy, window: UIWindow) {

        let sut = ListContactsViewController(viewModel: viewModel)
        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()

        waitForLoadData(on: viewModel)

        addTeardownBlock {
            window.rootViewController = nil
            window.isHidden = true
        }

        return (sut, viewModel, window)
    }

    /// viewDidLoad spawns a fire-and-forget Task capturing self; wait for it to
    /// finish so later assertions (and, for `makeSut`, the leak check) don't race it.
    private func waitForLoadData(on viewModel: ListContactsViewModelSpy, timeout: TimeInterval = 2.0) {
        let predicate = NSPredicate { _, _ in viewModel.displayMoviesCallCount > 0 }
        wait(for: [expectation(for: predicate, evaluatedWith: nil)], timeout: timeout)
    }

    private func waitForPresentedAlert(
        on sut: ListContactsViewController,
        timeout: TimeInterval = 5.0) -> UIAlertController? {

        let predicate = NSPredicate { _, _ in sut.presentedViewController != nil }
        wait(for: [expectation(for: predicate, evaluatedWith: nil)], timeout: timeout)

        return sut.presentedViewController as? UIAlertController
    }
}
