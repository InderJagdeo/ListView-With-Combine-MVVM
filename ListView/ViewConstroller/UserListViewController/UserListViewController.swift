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
    private let notificationManager = PushNotification()
    private let input: PassthroughSubject<UserListViewModel.Input, Never> = .init()
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, UserViewModel>
    private typealias DataSource = UITableViewDiffableDataSource<Section, UserViewModel>
    
    private var dataSource: DataSource?
    private var subscriptions = Set<AnyCancellable>()
    
    enum Section: CaseIterable {
        case user
    }
}

extension UserListViewController {
    // MARK: - UIView Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        bindPushNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.load)
    }
}

extension UserListViewController {
    // MARK: - Configurators
    
    func setupUI() {
        navigationItem.title = "User's List"
        setupTableView()
    }
    
    private func setupTableView() {
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
}

extension UserListViewController {
    // MARK: - Binding
    
    private func bindViewModel() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] event in
                switch event { 
                case .success(let users):
                    self?.updateTableView(with: users, animate: true)
                case .failure(let error):
                    print(error.localizedDescription)
                case .finish:
                    self?.refreshControl.endRefreshing()
                }
            })
            .store(in: &subscriptions)
    }
    
    private func bindPushNotification() {
        // Subscribe to changes in remoteNotificationPermission
        notificationManager.$pushNotificationPermission
            .sink { [weak self] permissionStatus in
                // Update your UI or take actions based on the permission status here
                self?.handlePermissionStatus(permissionStatus)
            }
            .store(in: &subscriptions)
        
        // Request remote notification permissions
        notificationManager.requestPushNotificationPermission()
    }
}

extension UserListViewController {
    // MARK: - User Defined Methods
    
    func handlePermissionStatus(_ status: PermissionStatus) {
        switch status {
        case .authorized:
            // Permission granted, you can enable notifications or perform actions here
            notificationManager.registerForRemoteNotifications()
            NetworkLogger.log(log: "Remote notification permission is authorized")
        default:
            // Permission denied, you can handle this case by showing a message to the user
            NetworkLogger.log(log: "Remote notification permission is not determind")
        }
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
    
    func updateTableView(with users: [UserViewModel], animate: Bool = true) {
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
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let userViewModel = dataSource?.itemIdentifier(for: indexPath),
              let user = viewModel.user(userViewModel) else {
            return
        }
        self.presentUserDetailViewController(user)
    }
}

