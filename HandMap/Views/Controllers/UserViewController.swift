//
//  UserViewController.swift
//  HandMap
//
//  Created by Акжан Калиматов on 06.09.2022.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


class UserViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userAvatarImage: UIImageView!
    
   
    @IBOutlet weak var cardView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fetchUser()
        userAvatarImage.layer.cornerRadius = 50
        userAvatarImage.layer.masksToBounds = true
        userAvatarImage.layer.borderWidth = 3
        userAvatarImage.layer.borderColor = UIColor(red: 0.1, green: 1, blue: 0.1, alpha: 1.0).cgColor
        
        cardView.layer.cornerRadius = 20
        
        
    }
    
    
    
  
    
    // To get data from database
    
    func fetchUser() {
                
                let userUID = Auth.auth().currentUser?.uid
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
                        self.userAvatarImage.image = image

                    }
                    
                    let userName = snapshot?.get("username") as? String
                   
                    
                    self.userNameLabel.text = "Hello, " + (userName)!
                    
                    
                    
                }
                
                
            }
            
        }

}




