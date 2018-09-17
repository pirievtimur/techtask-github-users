import UIKit

protocol UserListRouterProtocol {
    init(navigationController: UINavigationController)
    func showFollowers(user: GitHubUser)
}

class UserListRouter: UserListRouterProtocol {
    
    private let navigationController: UINavigationController
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showFollowers(user: GitHubUser) {
        let viewModel = FollowersViewModel(followersAPI: APIService(),
                                           user: user,
                                           router: self)
        let viewController = UsersListViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
