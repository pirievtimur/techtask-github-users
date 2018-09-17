//
//  ViewController.swift
//  github-users
//
//  Created by Timur Piriev on 9/17/18.
//  Copyright © 2018 Timur Piriev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UsersListViewController: UIViewController {

    private let viewModel = UsersListViewModel(apiService: APIService())
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        bindInput()
        bindOutput()
    }
    
    private func setupSubviews() {
        tableView.addSubview(refreshControl)
        tableView.register(UINib(nibName: UserCell.identifier, bundle: nil),
                           forCellReuseIdentifier: UserCell.identifier)
    }
    
    private func bindInput() {
        let load = refreshControl.rx.controlEvent(.valueChanged).asDriver(onErrorJustReturn: ())
        
        let loadNext = tableView.rx.contentOffset
            .debounce(0.7, scheduler: MainScheduler.instance)
            .filter { [weak self] offset in
                guard let weakSelf = self else { return false }
                return weakSelf.nearBottomEdge(contentOffset: offset, weakSelf.tableView)
            }
            .map { _ in
                
            }
            .asDriver(onErrorJustReturn: ())
        
        viewModel.bind(input: UsersListViewModel.Input(loadUsers: load,
                                                       loadNextUsers: loadNext))
    }

    private func bindOutput() {
        let output = viewModel.output()

        output
            .users
            .drive(tableView.rx.items(cellIdentifier: UserCell.identifier)) { _, model, cell in
                guard let userCell = cell as? UserCell else { return }
                userCell.updateWithModel(model: model)
            }.disposed(by: disposeBag)
        
        output
            .executing
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
    }
    
    private func nearBottomEdge(contentOffset: CGPoint, _ tableView: UITableView) -> Bool {
        let loadingNextPageOffset: CGFloat = view.bounds.height / 2
        return contentOffset.y + tableView.frame.size.height + loadingNextPageOffset > tableView.contentSize.height
    }
}

