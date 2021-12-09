//
//  FeedViewController.swift
//  EagleMakers
//
//  Created by Gage Condon on 12/4/21.
//

import UIKit
import SDWebImage

class FeedViewController: UIViewController {
    
    @IBOutlet var tableView : UITableView!
    
    var posts: Posts!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setToolbarHidden(true, animated: true)
        
        tableView.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        posts = Posts()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        posts.loadData {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ShowPost") {
            if let destination = segue.destination as? AddPostViewController {

               if let button:UIButton = sender as! UIButton? {
                   print(button.tag) //optional
                   destination.post = posts.postArray[button.tag]
               }
            }
        }
    }
    
    @objc func buttonTapped(_ sender:UIButton!){
        self.performSegue(withIdentifier: "ShowPost", sender: sender)
    }
    

}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        cell.configure(with: posts.postArray[indexPath.row])
        cell.detailsButton.tag = indexPath.row
        cell.detailsButton.addTarget(self, action: #selector(FeedViewController.buttonTapped(_:)), for: UIControl.Event.touchUpInside)
        //cell.delegate = self
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120+140+view.frame.size.width
    }

}
