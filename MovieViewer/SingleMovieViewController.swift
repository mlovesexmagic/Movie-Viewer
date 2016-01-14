//
//  SingleMovieViewController.swift
//  MovieViewer
//
//  Created by Zhipeng Mei on 1/12/16.
//  Copyright © 2016 Zhipeng Mei. All rights reserved.
//

import UIKit
import PKHUD

class SingleMovieViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var singleOverview: UILabel!
    @IBOutlet weak var singleTitleLabel: UILabel!
    @IBOutlet weak var singlePosterView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    var movie: NSDictionary!
    var refreshControl: UIRefreshControl!       //pull down refresh variable
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting size for scrollView
//        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: singleOverview.frame.origin.y + singleOverview.frame.size.height + 100)

        
        //scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, singleOverview.frame.origin.y + singleOverview.frame.size.height + 100)
        
        //scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, 2300)
        
        displaySingleView()
        refresh()
    
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height + singleOverview.frame.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displaySingleView () -> () {
        self.singleTitleLabel.text = movie["title"] as? String
        self.singleOverview.text = movie["overview"] as? String
        self.singleTitleLabel.sizeToFit()
        self.singleOverview.sizeToFit()
        
        let basePosterURL = "http://image.tmdb.org/t/p/w342"
        
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = NSURL(string: basePosterURL + posterPath)
            singlePosterView.setImageWithURL(imageURL!)
            
        }
    }
    
    //delay method part 1
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    //pull down refresh method part 2
    func onRefresh() {
        delay(1, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    
    //pull down refresh method for reload part 3
    func refresh(){
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 0.5)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.scrollView.addSubview(self.refreshControl)
    }

}
