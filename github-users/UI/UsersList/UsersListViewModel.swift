import RxSwift
import RxCocoa

class UsersListViewModel {
    
    struct Input {
        var loadUsers: Driver<Void>
        var loadNextUsers: Driver<Void>
    }
    
    struct Output {
        var users: Driver<[GitHubUser]>
        var executing: Driver<Bool>
    }
    
    private let disposeBag = DisposeBag()
    private let usersRelay = PublishRelay<[GitHubUser]>()
    private let executingRelay = BehaviorRelay<Bool>(value: false)
    private var users: [GitHubUser] = []
    private var loadMore: Bool = true
    
    private let apiService: GitHubUsersAPI
    
    init(apiService: GitHubUsersAPI) {
        self.apiService = apiService
    }
    
    func bind(input: Input) {
        input
            .loadUsers
            .asObservable()
            .flatMapLatest { [weak self] _ in self?.load() ?? .empty() }
            .bind(to: usersRelay)
            .disposed(by: disposeBag)
        
       input
            .loadNextUsers
            .asObservable()
            .flatMapLatest { [weak self] _ in self?.loadNext() ?? .empty() }
            .map { [weak self] in self?.users ?? [] + $0 }
            .bind(to: usersRelay)
            .disposed(by: disposeBag)
    }
    
    func output() -> Output {
        return .init(users: usersRelay.asDriver(onErrorJustReturn: []),
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