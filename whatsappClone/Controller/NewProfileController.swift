//
//  NewProfileController.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 23/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import UIKit
import ProgressHUD

class NewProfileController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    var email: String!
    var password: String!
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(email, password)
        
    }
    
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func cleanTextFields() {
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        countryTextField.text = ""
        cityTextField.text = ""
        phoneTextField.text = ""
    }
    
    private func registerUser(firstName: String, lastName: String, country: String, city: String, phone: String) {
        
        let fullName = firstName.appending(" ").appending(lastName)
        
        var tempDictionary: [String : Any] = [kFIRSTNAME : firstName,
                                              kLASTNAME : lastName,
                                              kFULLNAME : fullName,
                                              kCOUNTRY : country,
                                              kCITY : city,
                                              kPHONE : phone]
        
        if let avatarImage = avatarImage {
            let avatarData = avatarImage.jpegData(compressionQuality: 0.7)
            let avatarB64 = avatarData!.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
            tempDictionary[kAVATAR] = avatarB64
        } else {
            imageFromInitials(firstName: firstName, lastName: lastName) { (image) in
                let avatarData = image.jpegData(compressionQuality: 0.7)
                let avatarB64 = avatarData!.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
                tempDictionary[kAVATAR] = avatarB64
            }
        }
        
        finishRegistration(withValues: tempDictionary)
    }
    
    private func finishRegistration(withValues values: [String : Any]) {
        
        updateCurrentUserInFirestore(withValues: values) { (error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error.localizedDescription)
                    print(error.localizedDescription)
                }
                return
            }

            ProgressHUD.showSuccess("Registration successful")
            
            delay(duration: 1.5, completion: {
                self.goToApp()
            })
        }
    }
    
    private func goToApp() {
        
        cleanTextFields()
        dismissKeyboard()
        
        NotificationCenter.default.post(name: .USER_DID_LOGIN_NOTIFICATION, object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        let mainTabController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApp") as! UITabBarController
        self.present(mainTabController, animated: true, completion: nil)
    }
    
    // MARK: IBOUTLETS
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        cleanTextFields()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        dismissKeyboard()
        
        guard let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            let country = countryTextField.text,
            let city = cityTextField.text,
            let phone = phoneTextField.text,
            !firstName.isEmpty,
            !lastName.isEmpty,
            !country.isEmpty,
            !city.isEmpty,
            !phone.isEmpty else {
                ProgressHUD.showError("All fields are compulsory")
                return }
        
        ProgressHUD.show("Registering ..")
        
        FUser.registerUserWith(email: email, password: password, firstName: firstName, lastName: lastName) { (error) in
            
            if let error = error {
                ProgressHUD.dismiss()
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            
            self.registerUser(firstName: firstName, lastName: lastName, country: country, city: city, phone: phone)
        }
    }
}
