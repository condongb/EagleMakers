//
//  Steps.swift
//  EagleMakers
//
//  Created by Gage Condon on 12/5/21.
//

import Foundation
import Firebase

class Steps {
    var stepArray: [Step] = []
    
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(post: Post, completed: @escaping () -> ()) {
        guard post.documentID != "" else {
            return
        }
        db.collection("posts").document(post.documentID).collection("steps").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("Error: adding the snapshot listener")
                return completed()
            }
            self.stepArray = []
            for document in querySnapshot!.documents {
                let step = Step(dictionary: document.data())
                step.documentID = document.documentID
                self.stepArray.append(step)
            }
            if self.stepArray.count==0{
                let first_step = Step(title: "Step 1...", text: "", stepImage: UIImage(), stepImageURL: "", stepUserEmail: "", documentID: "")
                self.stepArray.append(first_step)
                
            }
            completed()
        }
    }
    
    
}
