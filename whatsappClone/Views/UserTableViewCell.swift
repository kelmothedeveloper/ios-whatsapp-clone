//
//  UserTableViewCell.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 23/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    var user: FUser?
    weak var delegate: UsersTableViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGesture()
    }
    
    func setupGesture() {
        avatarImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarPressed(_:)))
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    func generateCellWith(user: FUser, indexPath: IndexPath) {
        self.user = user
        self.fullNameLabel.text = user.fullname
        if !user.avatar.isEmpty {
            imageFromData(pictureData: user.avatar) { (image) in
                if let image = image?.circleMasked {
                    self.avatarImageView.image = image
                }
            }
        }
    }
    
    @objc func avatarPressed(_ sender: UITapGestureRecognizer) {
        guard let user = user else { return }
        delegate?.showProfile(user: user)
    }
    
}
