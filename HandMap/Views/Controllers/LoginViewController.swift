//
//  LoginViewController.swift
//  HandMap
//
//  Created by Акжан Калиматов on 01.09.2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    
 
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    
    @IBOutlet weak var loginBtn: UIButton!
    
    
    @IBOutlet weak var registerBtn: UILabel!
    
    @IBOutlet weak var errorLoginLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addGesture()
        
        setUpElements()
        
    }
    
    
    
    func addGesture() {

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
           tap.numberOfTapsRequired = 1
           self.registerBtn.isUserInteractionEnabled = true
           self.registerBtn.addGestureRecognizer(tap)
       }
    
    
    @objc func labelTapped(_ tap: UITapGestureRecognizer) {

            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let SecondVC = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
            self.navigationController?.pushViewController(SecondVC, animated: true)
       }
    
    
    
    
    
    func setUpElements() {
        errorLoginLabel.alpha = 0
        
    }
    
    
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        
        // TODO: Validate Text Fields
        
        // Create cleaned versions of the text field
        let email = emailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                // Couldn't sign in
                self.errorLoginLabel.text = error!.localizedDescription
                self.errorLoginLabel.alpha = 1
            }
            else {
                
                let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeTabViewController
                
                self.view.window?.rootViewController = homeViewController
                self.view.window?.makeKeyAndVisible()
            }
        }
        
    }
}
    
        

    
    
    
    
    
    
    
    
    
    
