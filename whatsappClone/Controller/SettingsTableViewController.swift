//
//  SettingsTableViewController.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 23/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    private func logout() {
        FUser.logOutCurrentUser { (isSuccess) in
            if isSuccess {
                self.showWelcomeVC()
            }
        }
    }
    
    private func showWelcomeVC() {
        let welcomeVC = StoryboardHelper.VC.welcome.viewController
        self.present(welcomeVC, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        logout()
    }
    
}

extension SettingsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
}
