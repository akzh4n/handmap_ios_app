//
//  LoginViewController.swift
//  HandMap
//
//  Created by Акжан Калиматов on 01.09.2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    
 
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var registerBtn: UILabel!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginBtn.layer.cornerRadius = 10
        
        setLogButton(enabled: false)
        activityView.isHidden = true
        
        
        emailTF.delegate = self
        passwordTF.delegate = self
        
        emailTF.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        
        
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
      

        self.addGesture()
        
        
        
    }
    
    
    
    func addGesture() {

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
           tap.numberOfTapsRequired = 1
           self.registerBtn.isUserInteractionEnabled = true
           self.registerBtn.addGestureRecognizer(tap)
       }
    
    
    @objc func labelTapped(_ tap: UITapGestureRecognizer) {

            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let RegisterVC = (storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.registerViewController) as? RegisterViewController)!
            self.navigationController?.pushViewController(RegisterVC, animated: true)
       }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
       
            NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow(sender:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
    
            NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
        
            
        }
    
        
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            NotificationCenter.default.removeObserver(self)
        }
    
    
    @objc func keyboardWillShow(sender: NSNotification) {
            guard let userInfo = sender.userInfo,
                  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
                  let currentTextField = UIResponder.currentFirst() as? UITextField else { return }

            print("foo - userInfo: \(userInfo)")
            print("foo - keyboardFrame: \(keyboardFrame)")
            print("foo - currentTextField: \(currentTextField)")
        
        
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedTextFieldFrame = view.convert(currentTextField.frame, from: currentTextField.superview)
        let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height

        // if textField bottom is below keyboard bottom - bump the frame up
        if textFieldBottomY > keyboardTopY {
            let textBoxY = convertedTextFieldFrame.origin.y
            let newFrameY = (textBoxY - keyboardTopY / 2) * -1
            view.frame.origin.y = newFrameY
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
            view.frame.origin.y = 0
    }
    
    @objc func textFieldChanged(_ target:UITextField) {
        let email = emailTF.text
        let password = passwordTF.text

        let formFilled = email != nil && email != "" && password != nil && password != ""
        setLogButton(enabled: formFilled)
    }
    
    func setLogButton(enabled:Bool) {
            if enabled {
                loginBtn.alpha = 1
                loginBtn.isEnabled = true
            } else {
                loginBtn.alpha = 0.5
                loginBtn.isEnabled = false
            }
        }
    
    
    
    func login() {
        
    }
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        view.endEditing(true)
        // TODO: Validate Text Fields
        
        // Create cleaned versions of the text field
        let email = emailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
    
        
        setLogButton(enabled: false)
        loginBtn.setTitle("", for: .normal)
        activityView.isHidden = false
        activityView.startAnimating()
        
        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
        
            if error != nil {
                // Couldn't sign in
                self.showAlert(with: "Error", and: "The user doesn`t exist")
                self.setLogButton(enabled: true)
                self.loginBtn.setTitle("OK", for: .normal)
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
               
            }
            else {
                
                let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeTabViewController
                
                self.view.window?.rootViewController = homeViewController
                self.view.window?.makeKeyAndVisible()
            }
        }
    }
}

extension LoginViewController {
    func showAlert(with title: String, and message: String, completion: @escaping () -> Void = { }) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            completion()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
    
        

    
    
    
    
    
    
    
    
    
    
