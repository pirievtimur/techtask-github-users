import RxSwift
import RxCocoa

protocol UsersListInputProtocol {
    var load: Driver<Void> { get set }
    var loadNext: Driver<Void> { get set }
    var userTap: Driver<IndexPath> { get set }
}

protocol UsersListOutputProtocol {
    var users: Driver<[GitHubUser]> { get }
    var executing: Driver<Bool> { get }
}

struct UsersListInput: UsersListInputProtocol {
    var load: Driver<Void>
    var loadNext: Driver<Void>
    var userTap: Driver<IndexPath>
}

struct UsersListOutput: UsersListOutputProtocol {
    var users: Driver<[GitHubUser]>
    var executing: Driver<Bool>
}

protocol UserListViewModelProtocol {
    var title: String { get }
    func bind(input: UsersListInputProtocol)
    func output() -> UsersListOutputProtocol
}

class UsersListViewModel: BaseViewModel, UserListViewModelProtocol {
    
    private let usersRelay = PublishRelay<[GitHubUser]>()
    private let executingRelay = BehaviorRelay<Bool>(value: false)
    private var users: [GitHubUser] = []
    private var loadMore: Bool = true
    
    private let apiService: GitHubUsersAPI
    private let router: UserListRouterProtocol
    
    init(apiService: GitHubUsersAPI, router: UserListRouterProtocol) {
        self.apiService = apiService
        self.router = router
    }
    
    // MARK: - UserListViewModelProtocol
    
    var title: String {
        return "Users list"
    }
    
    func bind(input: UsersListInputProtocol) {
        input
            .load
            .asObservable()
            .flatMapLatest { [weak self] _ in self?.load() ?? .empty() }
            .bind(to: usersRelay)
            .disposed(by: disposeBag)
        
       input
            .loadNext
            .asObservable()
            .flatMapLatest { [weak self] _ in self?.loadNext() ?? .empty() }
            .map { [weak self] in self?.users ?? [] + $0 }
            .bind(to: usersRelay)
            .disposed(by: disposeBag)
        
        input.userTap.asObservable().bind { [weak self] indexPath in
            guard let router = self?.router,
                let userModel = self?.users[indexPath.row] else { return }
            
            router.showFollowers(user: userModel)
        }.disposed(by: disposeBag)
    }
    
    func output() -> UsersListOutputProtocol {
        return UsersListOutput.init(users: usersRelay.asDriver(onErrorJustReturn: []),
                                   executing: executingRelay.asDriver())
    }
    
    private func load() -> Observable<[GitHubUser]> {
        users = []
        return loadUsers()
    }
    
    private func loadNext() -> Observable<[GitHubUser]> {
        return loadMore ? loadUsers() : Observable.empty()
    }
    
    private func loadUsers() -> Observable<[GitHubUser]> {
        let usersPerPage: UInt = 15
        
        return apiService
            .users(perPage: usersPerPage, since: users.last?.userId)
            .do(onNext: { [weak self] users in
                guard let weakSelf = self else { return }
                weakSelf.loadMore = users.count == usersPerPage
                weakSelf.users.append(contentsOf: users)
            },
            onError: { [weak self] _ in self?.executingRelay.accept(false) },
            onCompleted: { [weak self] in self?.executingRelay.accept(false) })
    }
}
