//
//  PostTableViewCell.swift
//  EagleMakers
//
//  Created by Gage Condon on 12/4/21.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var postTitleLabel: UILabel!
    @IBOutlet weak var postedByLabel: UILabel!
    //@IBOutlet var likesLabel: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    
    var post: Post!
    
    static let identifier = "PostTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "PostTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with post: Post) {
        //self.likesLabel.text = "\(post.numberOfLikes) Likes"
        self.postTitleLabel.text = post.title
        self.postedByLabel.text = "Posted by: \(post.postingUserEmail)"
        self.postImageView.image = post.mainPostImage
        let photoURL = URL(string: post.mainPostImageURL)
        self.postImageView.sd_setImage(with: photoURL)
        self.post = post
    }
    
}
