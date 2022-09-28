
<p align="left">
  <img src="https://github.com/manste1n/handmap_ios_app/blob/main/Screens/icon.png" width="110" title="main">
</p>






# HandMap

This application with minimal functionality is my first experience with Firebase and MapKit. 
By the way, connecting Pods was one of the most interesting experiences. 

I also gained experience with the design of the application, which was made simple and user friendly by the way.

You can try and take for yourself the experience of using the functionality of this project.


&nbsp;

<p align="center">
  <img src="https://github.com/manste1n/handmap_ios_app/blob/main/Screens/1.png" width="200" title="1">
  <img src="https://github.com/manste1n/handmap_ios_app/blob/main/Screens/2.png" width="200" title="2">
  
</p>

&nbsp;

<p align="center">
  <img src="https://github.com/manste1n/handmap_ios_app/blob/main/Screens/3.png" width="200" title="3">
  <img src="https://github.com/manste1n/handmap_ios_app/blob/main/Screens/4.png" width="200" title="4">
  
</p>

&nbsp;

<p align="center">
  <img src="https://github.com/manste1n/handmap_ios_app/blob/main/Screens/5.png" width="200" title="5">
  <img src="https://github.com/manste1n/handmap_ios_app/blob/main/Screens/6.png" width="200" title="6">
  
</p>




## Features

- [x] The app is available on the new version of Xcode and iOS 16.0 
- [x] Ability to register and log in using Firebase
- [x] Finding and pinpointing your exact location with MapKit
- [x] Russian Localizaiton + Beautiful UI/UX Design
- [x] Open to all devices 




## Code Review

 - Screen Sharing
 ```sh

           let firstActivityItem = "HandMap - is simple application by using Map API and Firebase."

           
           let secondActivityItem : NSURL = NSURL(string: "http://apple.com/")!
           
           
           let image : UIImage = UIImage(named: "icon")!
           let activityViewController : UIActivityViewController = UIActivityViewController(
               activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
           
    
           activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
           
     
           activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
           activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
           
           
           activityViewController.activityItemsConfiguration = [
           UIActivity.ActivityType.message
           ] as? UIActivityItemsConfigurationReading
           
           
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

``` 

 - Fetching User Info
 ```sh
func editFetchUser() {
                db.collection("newusers").document(userUID!).getDocument { [self] snapshot, error in
                if error != nil {
                    print("Error")
                }
                else {
                    let storage = Storage.storage()
                    var reference: StorageReference!
                    reference = storage.reference(forURL: "gs://exyourproject.com/useravatars/\(userUID!)")
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
``` 



 - Map Location Manager Delegate
 ```sh
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !isCurrentLocation {
            return
        }
        
        isCurrentLocation = false
        
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mainMapView.setRegion(region, animated: true)
        
        if self.mainMapView.annotations.count != 0 {
            annotation = self.mainMapView.annotations[0]
            self.mainMapView.removeAnnotation(annotation)
        }
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = location!.coordinate
        pointAnnotation.title = ""
        mainMapView.addAnnotation(pointAnnotation)
    }
}
``` 


## Installation

#### Requirements
- Xcode 13+ with an iOS 13.0+ simulator
- Firebase CocoaPods
- Apple MapKit

#### Installation steps
1. Clone the repo: `git clone https://github.com/manste1n/handmap_ios_app`
2. Register your Firebase Project by instructions in official page




&nbsp;



Thx for attention :3

You can support me by following :>
