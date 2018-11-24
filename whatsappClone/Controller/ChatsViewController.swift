//
//  ChatsViewController.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 24/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import UIKit

class ChatsViewController: UIViewController {
    
    
    
    
    
    @IBAction func newChatButtonPressed(_ sender: UIBarButtonItem) {
        
        let usersViewController = StoryboardHelper.VC.users.viewController
        
        self.navigationController?.pushViewController(usersViewController, animated: true)
        
        
        
    }
    
    
    
}
