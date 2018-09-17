//
//  UserCell.swift
//  github-users
//
//  Created by Timur Piriev on 9/17/18.
//  Copyright © 2018 Timur Piriev. All rights reserved.
//

import UIKit

protocol UserInfoPresentable {
    var userImageURL: URL? { get }
    var username: String { get }
    var profileURL: URL? { get }
}

class UserCell: UITableViewCell {
    
    static let identifier = "UserCell"

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileLink: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userImageView.image = nil
        usernameLabel.text = nil
        userProfileLink.text = nil
    }
    
    func updateWithModel(model: UserInfoPresentable) {
        usernameLabel.text = model.username
        if let profileURL = model.profileURL {
            userProfileLink.text = profileURL.absoluteString
        }
    }
}
