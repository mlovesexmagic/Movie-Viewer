//
//  CollectionMovieViewController.swift
//  MovieViewer
//
//  Created by Zhipeng Mei on 1/12/16.
//  Copyright © 2016 Zhipeng Mei. All rights reserved.
//

import UIKit
import PKHUD

class CollectionMovieViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var movies: [NSDictionary]?                 // Instance Variables
    var refreshControl: UIRefreshControl!       //pull down refresh variable

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self

        fetchNetworkData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //accessing API
    func fetchNetworkData(){
        //legit api key
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        
        //access the "now playing" endpoint
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            //loads "results" from "responseDictionary" into "movies"
                            //"self" indicates "movies" within this specfic view controller
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            //tells the collectionView to reload its data after network made its request
                            self.collectionView.reloadData()
                            
                            //refresh
                            self.refresh()
                    }
                }
        });
        task.resume()
    }
    
    //edited code provided by CodePath
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    //edited code provided by CodePath
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! CollectionMovieCell
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let baseURL = "http://image.tmdb.org/t/p/w342"
        
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = NSURL(string: baseURL + posterPath)
            cell.collectionPosterView.setImageWithURL((imageURL)!)
            cell.collectionTitleLabel.text = title
        }
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Selected cell number: \(indexPath.row)")
        
        let singleMovieViewController = SingleMovieViewController()
        
        singleMovieViewController.performSegueWithIdentifier("SingleMovie", sender: self)
    }
    
    //push to single view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let singleMovieViewController = segue.destinationViewController as! SingleMovieViewController
        singleMovieViewController.movie = movie
    }
    
    //delay method part 1 re-using code from MoviesView
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    //pull down refresh method part 2 re-using code from MoviesView
    func onRefresh() {
        delay(1, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    //pull down refresh method for reload part 3 re-using code from MoviesView
    func refresh(){
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 0.5)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.collectionView.addSubview(self.refreshControl)
    }
    
}
