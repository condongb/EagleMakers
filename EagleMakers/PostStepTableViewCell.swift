//
//  PostStepTableViewCell.swift
//  EagleMakers
//
//  Created by Gage Condon on 12/6/21.
//

import UIKit

class PostStepTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stepTitleLabel: UILabel!
    
    static let identifier = "PostStepTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "PostStepTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with step: Step) {
        self.stepTitleLabel.text = "\(step.title)"
    }
    
}
