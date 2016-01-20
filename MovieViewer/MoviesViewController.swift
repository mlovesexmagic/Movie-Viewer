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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    
    @IBOutlet weak var tableView: UITableView!  //tableView variable
    @IBOutlet weak var networkErrorView: UIView!    //networkErrorView
    @IBOutlet weak var searchBar: UISearchBar!
    
    //instace variable to be seem everywhere in the class
    // "?" means optional, less likely to crash
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var refreshControl: UIRefreshControl!       //pull down refresh variable
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkErrorView.hidden = true  //hides the network error view
        
        //initialize the cell as the MovieViewController to be the dataSource and delegate
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
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
        // "\(variable here)"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
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
                            
                            self.filteredMovies = self.movies
                            
                            //tells the tableView to reload its data after network made its request
                            self.tableView.reloadData()
                            
                            self.networkErrorView.hidden = true

                    }
                }else{
                    self.networkErrorView.hidden = false    //shows the network error

                }
        });
        task.resume()
    }
    
    //provided by CodePath
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //if movies has data (aka not nil)
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
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
        let movie = filteredMovies![indexPath.row]
        
        let title = movie["title"] as! String               //getting the movie's title
        let overview = movie["overview"] as! String         //getting the movie's overview
        
        let baseUrl = "https://image.tmdb.org/t/p/w342"      //movies' base url
        
        
        //getting the movie's specific image address
        if let posterPath = movie["poster_path"] as? String {
            let posterURL = NSURL(string: baseUrl + posterPath)
            
            let urlRequest = NSURLRequest(URL: posterURL!)
            
            cell.posterView.setImageWithURLRequest(urlRequest, placeholderImage: nil, success: { (request: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) -> Void in
                // response is nil when image returned from cache
                if response != nil {
                    print("network image")
                    cell.posterView.alpha = 0
                    cell.posterView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.posterView.alpha = 1
                    })
                } else {
                    print("cached Image")
                    cell.posterView.image = image
                }
                
                }, failure: { (request: NSURLRequest, response: NSHTTPURLResponse?, error: NSError) -> Void in
                    // There was an issue getting the image!
            })
        }
        
        cell.titleLabel.text = title                //display movie's title to MovieCell' titleLabel
        cell.overViewLable.text =  overview         //display movie's overview to MovieCell' overViewLable
//      cell.posterView.setImageWithURL(imageUrl!)  //display movie's image to MovieCell's posterView

        
        //print out the "row " and the indexPath to the console
        print("row \(indexPath.row)")
        
        return cell
    }
    
    
    //search function
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            filteredMovies = movies?.filter({ (movie: NSDictionary) -> Bool in
                if let title = movie["title"] as? String {
                    if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                        
                        return  true
                    } else {
                        return false
                    }
                }
                return false
            })
        }
        tableView.reloadData()
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
