//
//  RegisterViewController.swift
//  HandMap
//
//  Created by Акжан Калиматов on 01.09.2022.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var repasswordTextField: UITextField!
    
    
    
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var errorRegisterLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setUpElements()
       
    }

    func setUpElements() {
        errorRegisterLabel.alpha = 0
        
    }
    
    func validateFields() -> String? {
        
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            repasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            return "Please fill in all fields."
        }
        
        // Check passwords equality
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != repasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            return "The passwords don't match"
        }
        
        
        
        // Check if the password is secure
        let cleanedPassword1 = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPassword2 = repasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        if Utilities.isPasswordValid(cleanedPassword1) == false && Utilities.isPasswordValid(cleanedPassword2) == false {
            // Password isn`t secure enough
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
            
            
        return nil
    }
    
    
    
    
    
    @IBAction func registerBtnTapped(_ sender: Any) {
        
        // Valiate the fields
        
        let error = validateFields()
        if error != nil {
            
            showError(error!)
            
        }
        else {
            // Create cleaned versions of the data
            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
     
            
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result,err) in
                
                // Check for some errors
                
                if err != nil {
                    // There was a error creating the user
                    self.showError("Error creating the user")
                }
                else {
                    // The user was created successfully, now store the username
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: ["username": username, "uid": result!.user.uid]) { (error) in
                        
                        if error != nil {
                            // Show error message
                            
                            self.showError("Error saving user data")
                        }
                    }
                    
                    // Transition to the Home Screen
                    
                    self.transitionToHome()
                    
                    
                }
            }
            

        }
        
       
    }
    
    func showError(_ message: String) {
        errorRegisterLabel.text = message
        errorRegisterLabel.alpha = 1
    }
    
    func transitionToHome() {
        
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    


}
