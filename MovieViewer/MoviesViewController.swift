//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Zhipeng Mei on 1/12/16.
//  Copyright © 2016 Zhipeng Mei. All rights reserved.
//

import UIKit
import AFNetworking
import PKHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!  //tableView variable
    
    //instace variable to be seem everywhere in the class
    // "?" means optional, less likely to crash
    var movies: [NSDictionary]?
    
    var refreshControl: UIRefreshControl!       //pull down refresh variable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize the cell as the MovieViewController to be the dataSource and delegate
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchNetworkData()      //calling the "fetchNetworkData" method
        refresh()               //refreshing the view
        
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
                            
                            //tells the tableView to reload its data after network made its request
                            self.tableView.reloadData()
                    }
                }
        });
        task.resume()
    }
    
    //provided by CodePath
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //if movies has data (aka not nil)
        if let movies = movies {
            return movies.count
        }else{
            return 0
        }
        
    }
    
    //provided by CodePath
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // re-using the "MovieCell" for each index
        //indexPath tells where the cell is in the tableView
        //"as! MovieCell" down cast the cell we defined to be specific type/class "MovieCell"
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        //"!" means resonse is not nil
        //get single movie from movies at th same position as the cell
        let movie = movies![indexPath.row]
        
        let title = movie["title"] as! String               //getting the movie's title
        let overview = movie["overview"] as! String         //getting the movie's overview
        
        let posterPath = movie["poster_path"] as! String    //getting the movie's specific image address
        
        let baseUrl = "https://image.tmdb.org/t/p/w342"      //movies' base url
        let imageUrl = NSURL(string: baseUrl + posterPath)  //combine base url + image specific address
        
        cell.titleLabel.text = title                //display movie's title to MovieCell' titleLabel
        cell.overViewLable.text =  overview         //display movie's overview to MovieCell' overViewLable
        cell.posterView.setImageWithURL(imageUrl!)  //display movie's image to MovieCell's posterView

        
        //print out the "row " and the indexPath to the console
        print("row \(indexPath.row)")
        
        return cell
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
        
        self.tableView.addSubview(self.refreshControl)
    }
    
    

}
