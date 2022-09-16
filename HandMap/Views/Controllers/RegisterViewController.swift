//
//  RegisterViewController.swift
//  HandMap
//
//  Created by Акжан Калиматов on 01.09.2022.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var activityViewIn: UIActivityIndicatorView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    @IBOutlet weak var changeImageBtn: UIButton!
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var repasswordTextField: UITextField!

    
    @IBOutlet weak var registerBtn: UIButton!
    
    
    
    
    
    
    
    var imagePicker:UIImagePickerController!
    var urlString = ""
    
  
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        activityViewIn.isHidden = true
        registerBtn.layer.cornerRadius = 10
        
        
        setRegButton(enabled: false)
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        repasswordTextField.delegate = self
                
        usernameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        repasswordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor(red: 0.1, green: 1, blue: 0.1, alpha: 1.0).cgColor
        
        
            
       
       
    }
   
    


    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            usernameTextField.becomeFirstResponder()
       
            NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillAppear(notification:)),
            name: UIResponder.keyboardDidShowNotification, object: nil)
            
        }
    
        
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            usernameTextField.resignFirstResponder()
            emailTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
            repasswordTextField.resignFirstResponder()
            
            NotificationCenter.default.removeObserver(self)
        }
    
    
    @objc func keyboardWillAppear(notification: NSNotification){
            
            let info = notification.userInfo!
            let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            registerBtn.center = CGPoint(x: view.center.x,
                                            y: view.frame.height - keyboardFrame.height - 16.0 - registerBtn.frame.height / 2)
        
        }
    

    @objc func textFieldChanged(_ target:UITextField) {
        let username = usernameTextField.text
        let email = emailTextField.text
        let password = passwordTextField.text
        let repassword = repasswordTextField.text
        let formFilled = username != nil && username != "" && email != nil && email != "" && password != nil && password != "" && repassword != nil && repassword != ""
        setRegButton(enabled: formFilled)
    }

    
    func setRegButton(enabled:Bool) {
            if enabled {
                registerBtn.alpha = 1
                registerBtn.isEnabled = true
            } else {
                registerBtn.alpha = 0.5
                registerBtn.isEnabled = false
            }
        }
        
    
    @IBAction func changeImageBtnPressed(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
        
    }
    

    
    
    
    func upload(currentUserId: String, photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = Storage.storage().reference().child("useravatars").child(currentUserId)
        
        guard let imageData = profileImageView.image?.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            ref.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }
    
    
   
    

    func register(email: String?, password: String?, completion: @escaping (AuthResult) -> Void) {
        
        guard Validators.isFilledReg(username: usernameTextField.text,
                                  email: emailTextField.text,
                                  password: passwordTextField.text,
                                  repassword: repasswordTextField.text) else {
                                    completion(.failure(AuthError.notFilled))
                                    return
        }
        guard let email = email, let password = password else {
            completion(.failure(AuthError.unknownError))
            return  
        }
        
        guard Validators.isSimpleEmail(email) else {
            completion(.failure(AuthError.invalidEmail))
            return
        }
        
        guard Validators.isPasswordMatch(password: passwordTextField.text, repassword: repasswordTextField.text) else {
            completion(.failure(AuthError.passwordNotMatch))
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            self.upload(currentUserId: result.user.uid, photo: self.profileImageView.image!) { (myresult) in
                switch myresult {
                case .success(let url):
                    self.urlString = url.absoluteString
                    let db = Firestore.firestore()
                    db.collection("newusers").document(result.user.uid).setData([
                        "username": self.usernameTextField.text!,
                        "email": self.emailTextField.text!,
                        "password": self.passwordTextField.text!,
                        "avatarURL": url.absoluteString,
                        "uid": result.user.uid
                    ]) { (error) in
                        if let error = error {
                            completion(.failure(error))
                        }
                        completion(.success)
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
            
        }
    }
    
    
    
    
    
    @IBAction func registerBtnTapped(_ sender: Any) {
        setRegButton(enabled: false)
        registerBtn.setTitle("", for: .normal)
        activityViewIn.isHidden = false
        activityViewIn.startAnimating()
        
        register(email: emailTextField.text, password: passwordTextField.text) { (result) in
            switch result {
            case .success:
                self.showAlert(with: "Success", and: "You successfully registered!", completion: {
                    self.setRegButton(enabled: true)
                    self.registerBtn.setTitle("Sign Up", for: .normal)
                    self.activityViewIn.isHidden = true
                    self.activityViewIn.stopAnimating()
                    self.transitionToHome()
                })
            case .failure(let error):
                self.setRegButton(enabled: true)
                self.registerBtn.setTitle("Sign Up", for: .normal)
                self.activityViewIn.isHidden = true
                self.activityViewIn.stopAnimating()
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
       
    }
    
   
    
    func transitionToHome() {
        
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? HomeTabViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    


}

extension RegisterViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        profileImageView.image = image
    }
}


extension RegisterViewController {
    func showAlert(with title: String, and message: String, completion: @escaping () -> Void = { }) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            completion()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
