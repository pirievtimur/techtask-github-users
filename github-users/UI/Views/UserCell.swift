//
//  UserCell.swift
//  github-users
//
//  Created by Timur Piriev on 9/17/18.
//  Copyright © 2018 Timur Piriev. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

protocol UserInfoPresentable {
    var userImageURL: URL? { get }
    var username: String { get }
    var profileURL: URL? { get }
}

class UserCell: UITableViewCell {
    
    private let disposeBag = DisposeBag()
    
    static let identifier = "UserCell"

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileLink: UILabel!
    
    private var userHtmlURL: URL?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userImageView.image = nil
        usernameLabel.text = nil
        userProfileLink.text = nil
        userProfileLink.gestureRecognizers = nil
        userHtmlURL = nil
    }
    
    func updateWithModel(model: UserInfoPresentable) {
        usernameLabel.text = model.username
        
        if let profileURL = model.profileURL {
            userProfileLink.text = profileURL.absoluteString
            userHtmlURL = profileURL
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openURL))
            userProfileLink.addGestureRecognizer(tapGesture)
        }
        
        if let imageURL = model.userImageURL {
            userImageView.kf.indicatorType = .activity
            userImageView.kf.setImage(with: imageURL)
        }
    }
    
    @objc private func openURL() {
        guard let url = userHtmlURL else { return }
        let application = UIApplication.shared
        if application.canOpenURL(url) {
            application.open(url, options: [:], completionHandler: nil)
        }
    }
}
