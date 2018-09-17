//
//  AppDelegate.swift
//  github-users
//
//  Created by Timur Piriev on 9/17/18.
//  Copyright © 2018 Timur Piriev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = false
        let router = UserListRouter(navigationController: navigationController)
        let viewModel = UsersListViewModel(apiService: APIService(), router: router)
        let viewController = UsersListViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
        
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
        
        return true
    }
}

