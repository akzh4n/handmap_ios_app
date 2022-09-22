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
    
   
    @IBOutlet weak var editProfileGo: UILabel!
    
    
    @IBOutlet weak var sharedBtn: UILabel!
    
    
    @IBOutlet weak var cardView: UIView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.fetchUser()
        
        
        
        sharedBtn.isUserInteractionEnabled = true
        let shareTap = UITapGestureRecognizer(target: self, action: #selector(shareBtnPressed(_:)))
                sharedBtn.addGestureRecognizer(shareTap)
        
        
        
        userAvatarImage.layer.cornerRadius = 40
        userAvatarImage.layer.masksToBounds = true
        userAvatarImage.layer.borderWidth = 3
        userAvatarImage.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        cardView.layer.cornerRadius = 20
        
        
        
        self.addGesture()
        
        
    }
    
    
    // Share info about my app with your friends :D
    
    @objc func shareBtnPressed(_ sender: Any) {
        
        // Setting description
           let firstActivityItem = "HandMap - is simple application by using Map API and Firebase."

           // Setting url
           let secondActivityItem : NSURL = NSURL(string: "http://apple.com/")!
           
           // If you want to use an image
           let image : UIImage = UIImage(named: "icon")!
           let activityViewController : UIActivityViewController = UIActivityViewController(
               activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
           
           // This lines is for the popover you need to show in iPad
           activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
           
           // This line remove the arrow of the popover to show in iPad
           activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
           activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
           
           // Pre-configuring activity items
           activityViewController.activityItemsConfiguration = [
           UIActivity.ActivityType.message
           ] as? UIActivityItemsConfigurationReading
           
           // Anything you want to exclude
           activityViewController.excludedActivityTypes = [
               UIActivity.ActivityType.postToWeibo,
               UIActivity.ActivityType.print,
               UIActivity.ActivityType.assignToContact,
               UIActivity.ActivityType.saveToCameraRoll,
               UIActivity.ActivityType.addToReadingList,
               UIActivity.ActivityType.postToFlickr,
               UIActivity.ActivityType.postToVimeo,
               UIActivity.ActivityType.postToTencentWeibo,
               UIActivity.ActivityType.postToFacebook
           ]
           
           activityViewController.isModalInPresentation = true
           self.present(activityViewController, animated: true, completion: nil)
        
        
    }
    
    
    
    // Transition to Edit Profile View
    
    func addGesture() {

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
           tap.numberOfTapsRequired = 1
           self.editProfileGo.isUserInteractionEnabled = true
           self.editProfileGo.addGestureRecognizer(tap)
       }
    
    
    // There are no button, but we have this function, just click label to activate 
    @objc func labelTapped(_ tap: UITapGestureRecognizer) {

            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let EditUserVC = (storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.editUserViewController) as? EditProfileViewController)!
            self.navigationController?.pushViewController(EditUserVC, animated: true)
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




