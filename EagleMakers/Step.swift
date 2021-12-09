//
//  Step.swift
//  EagleMakers
//
//  Created by Gage Condon on 12/5/21.
//

import Foundation
import Firebase

class Step {
    var title: String
    var text: String
    var stepImage: UIImage
    var stepImageURL: String
    var stepUserEmail: String
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["title": title, "text": text, "stepImageURL": stepImageURL, "stepUserEmail": stepUserEmail, "documentID": documentID]
    }
    
    init(title: String, text: String, stepImage: UIImage, stepImageURL: String, stepUserEmail: String, documentID: String) {
        self.title = title
        self.text = text
        self.stepImage = stepImage
        self.stepImageURL = stepImageURL
        self.stepUserEmail = stepUserEmail
        self.documentID = documentID
    }
    
    convenience init() {
        let stepUserEmail = Auth.auth().currentUser?.email ?? "unknown email"
        self.init(title: "", text: "", stepImage: UIImage(), stepImageURL: "", stepUserEmail: stepUserEmail, documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let stepImageURL = dictionary["stepImageURL"] as! String? ?? ""
        let stepUserEmail = dictionary["stepUserEmail"] as! String? ?? ""
        let documentID = dictionary["documentID"] as! String? ?? ""
        
        self.init(title: title, text: text, stepImage: UIImage(), stepImageURL: stepImageURL, stepUserEmail: stepUserEmail, documentID: documentID)
    }
    
    func saveData(post: Post, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        
        
        let storage = Storage.storage()
        
        
        
        guard let photoData = self.stepImage.jpegData(compressionQuality: 0.5) else {
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
                
                self.stepImageURL = "\(url)"
        
        
                // create the dictionary
                let dataToSave: [String: Any] = self.dictionary
                if self.documentID == "" { //create a new document
                    var ref: DocumentReference? = nil
                    ref = db.collection("posts").document(post.documentID).collection("steps").addDocument(data: dataToSave) { (error) in
                        guard error == nil else {
                            print("Error adding document")
                            return completion(false)
                        }
                        self.documentID = ref!.documentID
                        print("Added document: \(self.documentID) to post: \(post.documentID)") //it worked
                        completion(true)
                    }
                } else { //else save to the existing documentID with .setData
                    let ref = db.collection("posts").document(post.documentID).collection("steps").document(self.documentID)
                    ref.setData(dataToSave) { (error) in
                        guard error == nil else {
                            print("Error updating document")
                            return completion(false)
                        }
                        print("Updated document: \(self.documentID) in post: \(post.documentID)") //it worked
                        completion(true)
                        
                    }
                    
                }
            }
        }
    }
}
