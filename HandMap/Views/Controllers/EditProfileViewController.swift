//
//  EditProfileViewController.swift
//  HandMap
//
//  Created by Акжан Калиматов on 17.09.2022.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class EditProfileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var editProfileImageView: UIImageView!
    
    
    @IBOutlet weak var changeImageBtn: UIButton!
    
    
    @IBOutlet weak var editUsernameTF: UITextField!
    
    
    @IBOutlet weak var editEmailTF: UITextField!
    
    
    @IBOutlet weak var editPasswordTF: UITextField!
    
    
    @IBOutlet weak var saveBtn: UIButton!
    
    
    @IBOutlet weak var editCardView: UIView!
    
    
    
    @IBOutlet weak var editActivityInView: UIActivityIndicatorView!
    
    
    let userUID = Auth.auth().currentUser?.uid
    let db = Firestore.firestore()
    
    var imagePicker:UIImagePickerController!
    var urlString = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        editActivityInView.isHidden = true
        
        
        editUsernameTF.delegate = self
        editEmailTF.delegate = self
        editPasswordTF.delegate = self
   
        
        editProfileImageView.layer.cornerRadius = 50
        editProfileImageView.layer.masksToBounds = true
        editProfileImageView.layer.borderWidth = 3
        editProfileImageView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        editCardView.layer.cornerRadius = 20
        saveBtn.layer.cornerRadius = 10
        
        
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        self.editFetchUser()
        

   
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
    
    
    func editFetchUser() {
                db.collection("newusers").document(userUID!).getDocument { [self] snapshot, error in
                if error != nil {
                    print("Error")
                }
                else {
                    let storage = Storage.storage()
                    var reference: StorageReference!
                    reference = storage.reference(forURL: "gs://handmap-ios.appspot.com/useravatars/\(userUID!)")
                    reference.downloadURL { (url, error) in
                        let data = NSData(contentsOf: url!)
                        let image = UIImage(data: data! as Data)
                        self.editProfileImageView.image = image

                    }
                    
                    let userName = snapshot?.get("username") as? String
                    let passWord = snapshot?.get("password") as? String
                    let email = snapshot?.get("email") as? String
                    
                    self.editUsernameTF.text = userName
                    self.editEmailTF.text = email
                    self.editPasswordTF.text = passWord
                    
                    
                    
                }
                
                
            }
            
        }

    
    
    @IBAction func editChangeImageBtnPressed(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    
    func upload(currentUserId: String, photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = Storage.storage().reference().child("useravatars").child(currentUserId)
        
        guard let imageData = editProfileImageView.image?.jpegData(compressionQuality: 0.4) else { return }
        
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
    
    
    func updateUser(username: String?, email: String?, password: String?, completion: @escaping (AuthResult) -> Void) {
        
        guard Validators.isFilledEditUser(username: editUsernameTF.text,
                                  email: editEmailTF.text,
                                  password: editPasswordTF.text) else {
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
    
            self.upload(currentUserId: userUID!, photo: self.editProfileImageView.image!) { (myresult) in
                switch myresult {
                case .success(let url):
                    self.urlString = url.absoluteString
                    let db = Firestore.firestore()
                    db.collection("newusers").document(self.userUID!).updateData([
                        "username": self.editUsernameTF.text!,
                        "email": self.editEmailTF.text!,
                        "password": self.editPasswordTF.text!,
                        "avatarURL": url.absoluteString,
                        "uid": self.userUID!
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
    
   
    
    
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        saveBtn.setTitle("", for: .normal)
        editActivityInView.isHidden = false
        editActivityInView.startAnimating()
        
        
        updateUser(username: editUsernameTF.text, email: editEmailTF.text, password: editPasswordTF.text) { (result) in
            switch result {
            case .success:
                self.showAlert(with: "Success", and: "You successfully updated profile!", completion: {
                    
                    self.saveBtn.setTitle("Save", for: .normal)
                    self.editActivityInView.isHidden = true
                    self.editActivityInView.stopAnimating()
                    self.transitionToHome()
                })
            case .failure(let error):
             
                self.saveBtn.setTitle("Save", for: .normal)
                self.editActivityInView.isHidden = true
                self.editActivityInView.stopAnimating()
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
        


        
    }
    
    func changeEmailAndPassword(email: String?, password: String?) {
        let user = Auth.auth().currentUser
        user?.updateEmail(to: email!) { error in
        if error != nil {
            print(AuthError.unknownError)
        } else {
           // Email updated
           }
        }
        user?.updatePassword(to: password!) { error in
        if error != nil {
            print(AuthError.unknownError)
        } else {
           // Password updated
           }
        }
       
    }
    
  
    
    
    
    func transitionToHome() {
        
        let HomeVC = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? HomeTabViewController
        
        view.window?.rootViewController = HomeVC
        view.window?.makeKeyAndVisible()
    }
    

}




extension EditProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        editProfileImageView.image = image
    }
}


extension EditProfileViewController {
    func showAlert(with title: String, and message: String, completion: @escaping () -> Void = { }) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            completion()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
