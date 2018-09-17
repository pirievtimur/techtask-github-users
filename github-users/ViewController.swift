//
//  ViewController.swift
//  github-users
//
//  Created by Timur Piriev on 9/17/18.
//  Copyright © 2018 Timur Piriev. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APIService().users(perPage: 100, since: nil).bind {
            print($0)
        }.disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

