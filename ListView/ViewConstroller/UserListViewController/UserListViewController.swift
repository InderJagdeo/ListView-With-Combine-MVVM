//
//  ViewController.swift
//  ListView
//
//  Created by Macbook on 29/11/22.
//

import UIKit
import Combine


class UserListViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet private weak var tableView: UITableView!

    private let viewModel = UserListViewModel()
    private let refreshControl = UIRefreshControl()
    private var subscriptions = Set<AnyCancellable>()
    private let input: PassthroughSubject<UserListViewModel.Input, Never> = .init()

    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, UserViewModel>
    private typealias DataSource = UITableViewDiffableDataSource<Section, UserViewModel>

    enum Section: CaseIterable {
        case user
    }

    private var dataSource: DataSource?

    // MARK: - UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set navigation item title
        navigationItem.title = "User's List"

        // Calling user defined methods
        bind()
        registerTableViewCell()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.load)
    }
}

extension UserListViewController {
    // MARK: - User Defined Methods
    
    private func registerTableViewCell() {
        tableView.register(ListCellView.nib, forCellReuseIdentifier: ListCellView.identifier)

        refreshControl.addTarget(self, action: #selector(pullToRefresh(sender:)), for: .valueChanged)
        tableView.refreshControl = refreshControl

        dataSource = DataSource(tableView: tableView, cellProvider: {(tableView, indexPath, user) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ListCellView.identifier) as? ListCellView else {
                return UITableViewCell()
            }
            cell.updateView(user)
            return cell
        })
    }

    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] event in
                switch event {
                case .fetchUserDidSuccess(let users):
                    self?.update(with: users, animate: true)
                case .fetchUserDidFail(let error):
                    print(error.localizedDescription)
                case .fetchUserDidFinish:
                    self?.refreshControl.endRefreshing()
                }
            })
            .store(in: &subscriptions)
    }
}

extension UserListViewController {
    // MARK: - Present UIViewController Methods
    private func presentUserDetailViewController(_ user: User) {
        let viewModel = UserDetailViewModel(user)

        let identifier = UserDetailViewController.identifier
        let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: identifier, creator: { coder -> UserDetailViewController? in
            let controller = UserDetailViewController(coder: coder, viewModel: viewModel)
            return controller
        })
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension UserListViewController {
    // MARK: - Action Methods
    @objc func pullToRefresh(sender: UIRefreshControl) {
        input.send(.refresh)
    }
}

extension UserListViewController {
    // MARK: - DataSource Methods
    func update(with users: [UserViewModel], animate: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(users, toSection: .user)
        dataSource?.apply(snapshot, animatingDifferences: animate)
    }

    func remove(_ users: [UserViewModel], animate: Bool = true) {
        guard let dataSource = dataSource else {return}
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems(users)
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
}

extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let userViewModel = dataSource?.itemIdentifier(for: indexPath),
              let user = viewModel.user(userViewModel) else {
                  return
              }
        self.presentUserDetailViewController(user)
    }
}

