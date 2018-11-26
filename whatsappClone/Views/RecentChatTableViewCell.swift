//
//  RecentChatTableViewCell.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 26/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import UIKit

protocol RecentChatsTableViewCellDelegate: class {
    func didTapAvatarImage(indexPath: IndexPath)
}

class RecentChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var messageCounterLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var indexPath: IndexPath!
    
    weak var delegate: RecentChatsTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        setupGesture()
    }
    
    func setupView() {
        messageCounterLabel.layer.cornerRadius = messageCounterLabel.frame.height / 2
        messageCounterLabel.layer.masksToBounds = true
    }

    func setupGesture() {
        avatarImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(_:)))
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    func generateCell(recentChat: NSDictionary, indexPath: IndexPath) {
        
        self.indexPath = indexPath
        
        self.nameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        self.lastMessageLabel.text = recentChat[kLASTMESSAGE] as? String
        self.messageCounterLabel.text = recentChat[kCOUNTER] as? String
        
        if let avatarString = recentChat[kAVATAR] as? String {
            imageFromData(pictureData: avatarString) { (image) in
                avatarImageView.image = image?.circleMasked
            }
        }
        
        if let counter = recentChat[kCOUNTER] as? Int, counter != 0 {
            self.messageCounterLabel.text = "\(counter)"
            self.messageCounterLabel.isHidden = false
        } else {
            self.messageCounterLabel.isHidden = true
        }
        
        var date: Date!
        
        if let created = recentChat[kDATE] as? String {
            
            if created.count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created)
            }
            
            
        } else {
            date = Date()
        }
        
        self.dateLabel.text = timeElapsed(date: date)        
    }
    
    @objc func avatarTapped(_ sender: UITapGestureRecognizer) {
        delegate?.didTapAvatarImage(indexPath: indexPath)
    }
    
}
