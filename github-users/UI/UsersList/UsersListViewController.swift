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
import SnapKit

class UsersListViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    private let viewModel: UserListViewModelProtocol
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.addSubview(refreshControl)
        tableView.register(UINib(nibName: UserCell.identifier, bundle: nil),
                           forCellReuseIdentifier: UserCell.identifier)
        
        return tableView
    }()
    
    private let refreshControl = UIRefreshControl()
    
    init(viewModel: UserListViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil,
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        
        setupSubviews()
        bindInput()
        bindOutput()
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.snp.top)
            $0.bottom.equalTo(view.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func bindInput() {
        let load = refreshControl.rx.controlEvent(.valueChanged).asDriver(onErrorJustReturn: ())
        
        let loadNext = tableView.rx.contentOffset
            .debounce(0.7, scheduler: MainScheduler.instance)
            .filter { [weak self] offset in
                guard let weakSelf = self else { return false }
                return weakSelf.nearBottomEdge(contentOffset: offset, weakSelf.tableView)
            }
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
        
        let didTap = tableView.rx.itemSelected.asDriver()
        
        viewModel.bind(input: UsersListInput(load: load,
                                             loadNext: loadNext,
                                             userTap: didTap))
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

