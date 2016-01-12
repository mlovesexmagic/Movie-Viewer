//
//  MovieCell.swift
//  MovieView
//
//  Created by Zhipeng Mei on 1/7/16.
//  Copyright © 2016 Zhipeng Mei. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overViewLabel: UILabel!
    
    @IBOutlet weak var posterView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //animation for fading in image
    func imageFadeIn() {
            UIView.animateWithDuration(1.0, animations: {
                self.posterView.alpha = 0.0
                self.posterView.alpha = 1.0
            })
    }

}
