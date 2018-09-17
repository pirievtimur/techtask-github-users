import RxCocoa
import RxSwift

class FollowersViewModel: BaseViewModel, UserListViewModelProtocol {
    
    private var page: UInt = 1
    private var loadMore: Bool = true
    private var followers: [GitHubUser] = []
    private let followersRelay = PublishRelay<[GitHubUser]>()
    private let executingRelay = BehaviorRelay<Bool>(value: false)
    
    private let followersAPI: GitHubUserFollowersAPI
    private let user: GitHubUser
    private let router: UserListRouterProtocol
    
    init(followersAPI: GitHubUserFollowersAPI, user: GitHubUser, router: UserListRouterProtocol) {
        self.followersAPI = followersAPI
        self.user = user
        self.router = router
    }
    
    // MARK: - UserListViewModelProtocol
    
    var title: String {
        return "\(user.login)'s followers"
    }
    
    func bind(input: UsersListInputProtocol) {
        input
            .load
            .asObservable()
            .flatMapLatest { [weak self] _ in self?.load() ?? .empty() }
            .bind(to: followersRelay)
            .disposed(by: disposeBag)
        
        input
            .loadNext
            .asObservable()
            .flatMapLatest { [weak self] _ in self?.loadNext() ?? .empty() }
            .map { [weak self] in self?.followers ?? [] + $0 }
            .bind(to: followersRelay)
            .disposed(by: disposeBag)
        
        input.userTap.asObservable().bind { [weak self] indexPath in
            guard let router = self?.router,
                let userModel = self?.followers[indexPath.row] else { return }
            
            router.showFollowers(user: userModel)
            }.disposed(by: disposeBag)
    }
    
    func output() -> UsersListOutputProtocol {
        return UsersListOutput.init(users: followersRelay.asDriver(onErrorJustReturn: []),
                                    executing: executingRelay.asDriver())
    }
    
    private func load() -> Observable<[GitHubUser]> {
        followers = []
        page = 1
        return loadFollowers()
    }
    
    private func loadNext() -> Observable<[GitHubUser]> {
        return loadMore ? loadFollowers() : Observable.empty()
    }
    
    private func loadFollowers() -> Observable<[GitHubUser]> {
        let perPage: UInt = 15

        guard let url = user.followersURLString else { return .empty() }
        
        return followersAPI
            .followers(urlString: url, page: page, perPage: perPage)
            .do(onNext: { [weak self] followers in
                guard let weakSelf = self else { return }
                weakSelf.loadMore = followers.count == perPage
                weakSelf.followers.append(contentsOf: followers)
            },
            onError: { [weak self] _ in self?.executingRelay.accept(false) },
            onCompleted: { [weak self] in
                self?.executingRelay.accept(false)
                self?.page += 1
            })
    }
}
