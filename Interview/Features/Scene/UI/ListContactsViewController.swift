import UIKit

public final class ListContactsViewController: UIViewController {
    // MARK: - UI
    private var viewModel: ListContactsViewModelProtocol
    
    private(set) lazy var activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.hidesWhenStopped = true
        activity.startAnimating()
        activity.accessibilityTraits = .updatesFrequently
        return activity
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 120
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(ContactCell.self, forCellReuseIdentifier: ContactCell.identifier)
        tableView.backgroundView = activity
        tableView.tableFooterView = UIView()
        tableView.accessibilityTraits = .updatesFrequently
        return tableView
    }()
        
    public init(viewModel: ListContactsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { nil }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lista de Contatos"
        configureViews()
        
        Task {
            do {
                try await loadData()
            } catch {
                show(alert: "Hey you!", message: error.localizedDescription)
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.setDelegate = self
    }
}

extension ListContactsViewController: ViewModelDelegate  {
    // MARK: - ViewModelDelegate Protocol
    public func isLegacy(name: String) {
        show(
            alert: "Atenção",
            message: "Você tocou no contato sorteado, com o nome de \(name)."
        )
    }
    
    public func notNotLegacy(name: String) {
        show(
            alert: "Você tocou em",
            message: name
        )
    }
}

extension ListContactsViewController {
    private func loadData() async throws {
        if let result = try await viewModel.displayMovies() {
            switch result {
                case let .success(contacts):
                self.viewModel.model.insert(contacts)
                self.activity.stopAnimating()
                self.tableView.reloadData()
            case let .failure(error):
                self.show(alert: "Hey you!", message: error.localizedDescription)
            }
        }
    }
   
    private func show(alert title: String, message: String?) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "FECHAR",
            style: .default,
            handler: nil)
        )
        
        present(alert, animated: true)
    }
    
    private func configureViews() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func makeAnimation(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath) {
            
        cell.transform = CGAffineTransform(
            translationX: 0,
            y: tableView.bounds.size.height / 2).scaledBy(
                x: 0.5,
                y: 0.5
            )
        
        UIView.animate(
            withDuration: 0.6,
            delay: .zero * Double(indexPath.row),
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.9,
            options: .curveEaseInOut, animations: {
            cell.transform = CGAffineTransform.identity
        })
    }
}

// MARK: - UITableViewDelegate Protocol
extension ListContactsViewController: UITableViewDelegate {
    public func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.autoresizingMask.contains(
            [.flexibleHeight,
             .flexibleWidth
            ]) ? 80 : 130
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.isLegacy(index: indexPath)
    }
}

// MARK: - UITableViewDataSource Protocol
extension ListContactsViewController: UITableViewDataSource {
    public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        viewModel.model.first?.count ?? .zero
    }
    
    public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: ContactCell.identifier,
            for: indexPath) as? ContactCell {
            if let model = viewModel.model.first?[indexPath.row] {
                cell.setup(cell: model)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    public func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath) {
            
        makeAnimation(
            tableView,
            willDisplay: cell,
            forRowAt: indexPath
        )
    }
}
