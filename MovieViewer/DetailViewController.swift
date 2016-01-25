//
//  DetailViewController.swift
//  MovieViewer
//
//  Created by Zhipeng Mei on 1/22/16.
//  Copyright © 2016 Zhipeng Mei. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterView: UIImageView!         //for movie's image
    @IBOutlet weak var titleLabel: UILabel!             //for movie's title
    @IBOutlet weak var overviewLabel: UILabel!          //for movie's description
    @IBOutlet weak var scrollView: UIScrollView!        //for scrolling
//    @IBOutlet weak var infoView: UIView!                //get the exact high of the scroll view
    @IBOutlet weak var releaseDate: UILabel!            //releaseDate
    @IBOutlet weak var score: UILabel!                  //movie's score
    @IBOutlet weak var poster_path2: UIImageView!
    
    var movie: NSDictionary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        
        //"contentSize" enables the screen to scroll
        //"scrollView.frame.size.width" is the width of the scroll view
        //"infoView.frame.origin.y" is height of the image view
        //"+ infoView.frame.size.height" extends to the hidden area below the image view
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: overviewLabel.frame.size.height + scrollView.frame.size.height)
        
        
        
        //getting the movie's
        let title = movie["original_title"] as! String
        titleLabel.text = title
        titleLabel.sizeToFit()

        //get movie's release date
        let date = movie["release_date"] as! String
        releaseDate.text = date
        
        //get the movie's score
        let votes = movie["vote_average"] as! NSNumber
        let vote = votes.stringValue
        score.text = "\(vote)/10"
        
        let overview = movie["overview"] as! String
        overviewLabel.text = overview
        //displays the entire string fits the screen, only for non-autolayout
        overviewLabel.sizeToFit()
        
        let baseUrl = "https://image.tmdb.org/t/p/w342"      //movies' base url
        
        //if poster_path is nil then skip everything inside { }
        //getting the movie's specific image address
        if let posterPath = nullToNil(movie["backdrop_path"]) as! String? {
            let imageUrl = NSURL(string: baseUrl + posterPath)              //combine base url + image specific address
            posterView.setImageWithURL(imageUrl!)                           //display movie's image to MovieCell's posterView
        
            let posterPath2 = nullToNil(movie["poster_path"]) as! String?
            let imageUrl2 = NSURL(string: baseUrl + posterPath2!)
            poster_path2.setImageWithURL(imageUrl2!)
        
        } else if let posterPath = nullToNil(movie["poster_path"]) as! String? {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            poster_path2.setImageWithURL(imageUrl!)
        }
    }
    
    
    
    //method to check value is empty or not
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
