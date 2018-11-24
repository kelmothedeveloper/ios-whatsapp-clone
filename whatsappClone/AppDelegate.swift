//
//  AppDelegate.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 23/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        setupGlobalViews()
        // Auto Login
        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            if user != nil {
                if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
                    DispatchQueue.main.async {
                        self.goToApp()
                    }
                }
            }
        })
        return true
    }
    
    func setupGlobalViews() {
        UINavigationBar.appearance().prefersLargeTitles = true
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}

    
    func goToApp() {
        NotificationCenter.default.post(name: .USER_DID_LOGIN_NOTIFICATION, object: nil, userInfo: [kUSERID : FUser.currentId()])
        let mainTabBarController = StoryboardHelper.VC.main.viewController
        self.window?.rootViewController = mainTabBarController
    }
}

