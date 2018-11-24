//
//  ProfileViewTableViewController.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 24/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import UIKit

class ProfileViewTableViewController: UITableViewController {
    
    var user: FUser!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var blockUserButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        setupViews()
    }
    
    func setupNavigation() {
        self.title = "Profile"
    }
    
    func setupTableView() {
        
    }
    
    func setupViews() {

        fullNameLabel.text = user.fullname
        phoneNumberLabel.text = user.phoneNumber

        imageFromData(pictureData: user.avatar) { (image) in
            avatarImageView.image = image?.circleMasked
        }
        
        updateBlockStatus()
        
    }
    
    private func isCurrentUser() -> Bool {
        return user.objectId == FUser.currentId()
    }
    
    func updateBlockStatus() {
        
            blockUserButton.isHidden = isCurrentUser()
            messageButton.isHidden = isCurrentUser()
            callButton.isHidden = isCurrentUser()
        
        if FUser.currentUser()!.blockedUsers.contains(user.objectId) {
            blockUserButton.setTitle("Unblock user", for: .normal)
        } else {
            blockUserButton.setTitle("Block", for: .normal)
        }
        
    }
    
    
    @IBAction func callButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func messageButtonPressed(_ sender: UIButton) {
    }
    
    
    @IBAction func blockUserButtonPressed(_ sender: UIButton) {
        
        var currentBlockedIds = FUser.currentUser()!.blockedUsers
        if currentBlockedIds.contains(user.objectId) {
            let index = currentBlockedIds.firstIndex(of: user.objectId)
            currentBlockedIds.remove(at: index!)
        } else {
            currentBlockedIds.append(user.objectId)
        }
                
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID: currentBlockedIds]) { (error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                self.updateBlockStatus()
            }
        }
    }
}

extension ProfileViewTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 0 : 30
        
        
    }
}
