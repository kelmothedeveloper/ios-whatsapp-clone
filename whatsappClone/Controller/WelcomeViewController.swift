//
//  ViewController.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 23/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import UIKit
import ProgressHUD

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: IBActions
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        dismissKeyboard()
        
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty else {
                ProgressHUD.showError("Email and password is missing!")
                return }
        
        loginUser(email: email, password: password)
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            let passwordConfirmation = passwordConfirmationTextField.text,
            !email.isEmpty,
            !password.isEmpty,
            !passwordConfirmation.isEmpty else {
                ProgressHUD.showError("All fields are required")
                return }
        
        guard password == passwordConfirmation else {
            ProgressHUD.showError("Passwords don't match")
            return }
        
        register()
    }
    
    // MARK: Helper Functions
    
    private func loginUser(email: String, password: String) {
        
        ProgressHUD.show("Login ..")
        
        FUser.loginUserWith(email: email, password: password) { (error) in
            
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            
            self.goToApp()
        }
    }
    
    private func register() {
        performSegue(withIdentifier: "segueNewProfile", sender: nil)
        cleanTextFields()
    }
    
    private func dismissKeyboard() {
        view.endEditing(false)
    }
    
    private func cleanTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
        passwordConfirmationTextField.text = ""
    }
    
    private func goToApp() {
        
        ProgressHUD.dismiss()
        cleanTextFields()
        dismissKeyboard()
        
        NotificationCenter.default.post(name: .USER_DID_LOGIN_NOTIFICATION, object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        let mainTabController = StoryboardHelper.VC.main.viewController
        self.present(mainTabController, animated: true, completion: nil)
        
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueNewProfile" {
            let viewController = segue.destination as! NewProfileController
            viewController.email = emailTextField.text!
            viewController.password = passwordTextField.text!
        }
    }
    
}

