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
        // TO DO open user followers
    }
}
