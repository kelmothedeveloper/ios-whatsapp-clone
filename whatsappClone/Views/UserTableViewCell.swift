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
    
    func generateCellWith(fUser: FUser, indexPath: IndexPath) {
        self.fullNameLabel.text = fUser.fullname
        if !fUser.avatar.isEmpty {
            imageFromData(pictureData: fUser.avatar) { (image) in
                if let image = image?.circleMasked {
                    self.avatarImageView.image = image
                }
            }
        }
    }
    
}
