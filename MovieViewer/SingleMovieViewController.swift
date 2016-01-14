//
//  SingleMovieViewController.swift
//  MovieViewer
//
//  Created by Zhipeng Mei on 1/12/16.
//  Copyright © 2016 Zhipeng Mei. All rights reserved.
//

import UIKit

class SingleMovieViewController: UIViewController {

    @IBOutlet weak var singleOverview: UILabel!
    @IBOutlet weak var singleTitleLabel: UILabel!
    @IBOutlet weak var singlePosterView: UIImageView!
    
    var singleOverView = ""
    var singleTitle = ""
    var posterURL = NSURL(fileURLWithPath: " ")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        singleOverview.text = singleOverView
        singleTitleLabel.text = singleTitle
        singlePosterView.setImageWithURL(posterURL)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
