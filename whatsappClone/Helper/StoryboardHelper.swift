//
//  StoryboardHelper.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 24/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import UIKit

struct StoryboardHelper {
    
    static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    enum VC {
        
        case main
        case welcome
        case users
        case profileView
        
        var viewController: UIViewController {
            switch self {
            case .main:
                return storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            case .welcome:
                return storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
            case .users:
                return storyboard.instantiateViewController(withIdentifier: "UsersTableViewController") as! UsersTableViewController
            case .profileView:
                return storyboard.instantiateViewController(withIdentifier: "ProfileViewTableViewController") as! ProfileViewTableViewController
            }
        }
    }
    
    
//    static func present(_ viewController: UIViewController, to destination: VC, completion: (() -> Void)?) {
//        viewController.present(destination.viewController, animated: true, completion: completion)
//    }
//
//    static func show(_ viewController: UIViewController, to destination: VC, completion: (() -> Void)?) {
//        viewController.navigationController?.pushViewController(destination.viewController, animated: true)
//    }
    
    
}
