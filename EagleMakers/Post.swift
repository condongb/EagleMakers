//
//  Post.swift
//  EagleMakers
//
//  Created by Gage Condon on 12/4/21.
//

import Foundation
import Firebase

class Post {
    var title: String
    var postingUserID: String
    var postingUserEmail: String
    var mainPostImage: UIImage
    var mainPostImageURL: String
    var numberOfLikes: Int 
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["title": title, "postingUserID": postingUserID, "postingUserEmail": postingUserEmail, "mainPostImageURL": mainPostImageURL, "numberOfLikes": numberOfLikes]
    }
    
    init(title: String, postingUserID: String, postingUserEmail: String, mainPostImage: UIImage, mainPostImageURL: String, numberOfLikes: Int, documentID: String) {
        self.title = title
        self.postingUserID = postingUserID
        self.postingUserEmail = postingUserEmail
        self.mainPostImage = mainPostImage
        self.mainPostImageURL = mainPostImageURL
        self.numberOfLikes = numberOfLikes
        self.documentID = documentID
    }
    
    convenience init() {
        let postingUserID = Auth.auth().currentUser?.uid ?? ""
        let postingUserEmail = Auth.auth().currentUser?.email ?? "unknown email"
        self.init(title: "", postingUserID: postingUserID, postingUserEmail: postingUserEmail, mainPostImage: UIImage(), mainPostImageURL: "", numberOfLikes: 0, documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        let postingUserEmail = dictionary["postingUserEmail"] as! String? ?? ""
        let mainPostImageURL = dictionary["mainPostImageURL"] as! String? ?? ""
        let numberOfLikes = dictionary["numberOfLikes"] as! Int? ?? 0
        self.init(title: title, postingUserID: postingUserID, postingUserEmail: postingUserEmail, mainPostImage: UIImage(), mainPostImageURL: mainPostImageURL, numberOfLikes: numberOfLikes, documentID: "")
    }
    
    func saveData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        // grab the user ID
        guard let postingUserID = Auth.auth().currentUser?.uid else {
            print("ERROR: Could not save data because we don't have a valid postingUserID.")
            return completion(false)
        }
        self.postingUserID = postingUserID
        
        
        guard let photoData = self.mainPostImage.jpegData(compressionQuality: 0.5) else {
            print("ERROR: Could not convert image to data")
            return
        }
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
                
        if self.documentID == ""{
            self.documentID = UUID().uuidString
        }
                
        let storageRef = storage.reference().child(self.documentID).child(self.documentID)
                
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) { (metadata, error) in
            if let error = error {
                print("ERROR: Uplaod for ref \(uploadMetaData) failed. \(error.localizedDescription)")
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print("Upload to FirebaseStorage was successful!")
            storageRef.downloadURL { (url, error) in
                guard error == nil else {
                    print("ERROR: Couldn't create a download url \(error!.localizedDescription)")
                    return completion(false)
                }
                guard let url = url else {
                    print("ERROR: Couldn't create a download url and this should not have happened because we've already show there was no error.")
                    return completion(false)
                }
                
                self.mainPostImageURL = "\(url)"
        
                // create the dictionary
                let dataToSave: [String: Any] = self.dictionary
                if self.documentID == "" { //create a new document
                    var ref: DocumentReference? = nil
                    ref = db.collection("posts").addDocument(data: dataToSave) { (error) in
                        guard error == nil else {
                            print("Error adding document")
                            return completion(false)
                        }
                        self.documentID = ref!.documentID
                        print("Added document: \(self.documentID)") //it worked
                        completion(true)
                    }
                } else { //else save to the existing documentID with .setData
                    let ref = db.collection("posts").document(self.documentID)
                    ref.setData(dataToSave) { (error) in
                        guard error == nil else {
                            print("Error updating document")
                            return completion(false)
                        }
                        print("Updated document: \(self.documentID)") //it worked
                        completion(true)
                    }
                }
            }
        }
    }
    
 
}
