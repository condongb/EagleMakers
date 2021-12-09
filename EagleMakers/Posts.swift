//
//  Posts.swift
//  EagleMakers
//
//  Created by Gage Condon on 12/4/21.
//

import Foundation
import Firebase

class Posts {
    var postArray: [Post] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("posts").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("Error: adding the snapshot listener")
                return completed()
            }
            self.postArray = []
            for document in querySnapshot!.documents {
                let post = Post(dictionary: document.data())
                post.documentID = document.documentID
                self.postArray.append(post)
            }
            completed()
        }
    }
}
