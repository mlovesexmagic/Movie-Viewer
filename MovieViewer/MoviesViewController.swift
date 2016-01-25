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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var tableView: UITableView!      //tableView variable
    @IBOutlet var collectionView: UICollectionView!    //collectionView variable
    @IBOutlet weak var networkErrorView: UIView!    //network error view
    @IBOutlet weak var searchBar: UISearchBar!      //search movies
    @IBOutlet weak var swapButton: UIButton!        //button for sawpping
    
    //instace variable to be seem everywhere in the class
    // "?" means optional, less likely to crash
    var movies: [NSDictionary]?
    var endpoint:String!        //for storing the endpoint, toprated or nowplaying
    var refreshControl: UIRefreshControl!         //refresh reload
    var filteredMovies: [NSDictionary]?     //variable for storing filtered/searched movies

    //
    var currentTableView: Bool = true
    var currentcollectionView: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.barStyle = UIBarStyle.Black

        
        //initialize the cell as the MovieViewController to be the dataSource and delegate
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        
        networkErrorView.hidden = true
        
        networkRequest()    //call networkRequest method
        refresh()         //refresh animation spinning
    }
    
    func networkRequest() {
        PKHUD.sharedHUD.show()  //show the HUD
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"       //legit api key
        //access the "now playing" endpoint
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
                            
                            //tells the tableView/collectionView to reload its data after network made its request
                            self.refreshControl.endRefreshing()     //end refresh
                            self.networkErrorView.hidden = true     //hide networkErrorView
                            PKHUD.sharedHUD.hide()
                            self.tableView.reloadData()
                            self.collectionView.reloadData()

                    }
                } else {
                    print("There's an error")
                    self.networkErrorView.hidden = false    //show networkErrorView
                    PKHUD.sharedHUD.hide()
                }
        });
        task.resume()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if movies has data (aka not nil)
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // re-using the "MovieCell" for each index
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        // No color when the user selects cell
        cell.selectionStyle = .Gray
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.grayColor()
        cell.selectedBackgroundView = backgroundView

        
        
        
        //get single movie from movies at th same position as the cell
        let movie = filteredMovies![indexPath.row]
        
        let title = movie["title"] as! String               //getting the movie's title
        let overview = movie["overview"] as! String         //getting the movie's overview
        cell.titleLabel.text = title                        //display movie's title to MovieCell' titleLabel
        cell.overViewLable.text =  overview                 //display movie's overview to MovieCell' overViewLable
        
        let low_resolution = "https://image.tmdb.org/t/p/w45"       //low resolution image's address
        let high_resolution = "https://image.tmdb.org/t/p/original" //high resolution image's address

        let posterPath = movie["poster_path"] as! String?
        let smallImage = NSURL(string: low_resolution + posterPath!)
        let largeImage = NSURL(string: high_resolution + posterPath!)
        
        let smallImageRequest = NSURLRequest(URL: smallImage!)
        let largeImageRequest = NSURLRequest(URL: largeImage!)
        
        //get the movie's images
        cell.posterView.setImageWithURLRequest(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                cell.posterView.alpha = 0.0
                cell.posterView.image = smallImage;
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    cell.posterView.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        cell.posterView.setImageWithURLRequest(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                cell.posterView.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                })
            },
            failure: { (request, response, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
        })
        //print out the "row " and the indexPath to the console
        print("row \(indexPath.row)")
        return cell
    }

    //transfer data from "MovieViewController" to "DetailViewcontroller"
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       

        print("prepare for segue called")

        if currentTableView == true {
            // do somethings
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let movie = movies![indexPath!.item]
            let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.movie = movie
            
        } else {
            // do somethings else
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPathForCell(cell)
            let movie = movies![indexPath!.item]
            let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.movie = movie
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        PKHUD.sharedHUD.hide(afterDelay: 0.4)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(self.refreshControl)
    }
    
    //method search part 1
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

    //method search part 2
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        UIView.animateWithDuration(1, animations: {
            self.searchBar.setShowsCancelButton(true, animated: true)
        })
    }
    
    //method search part 3
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        resetSearchBar(searchBar)
        self.filteredMovies = self.movies
        self.tableView.reloadData()
    }
    
    //method search part 4
    func resetSearchBar (searchBar: UISearchBar) -> () {
        UIView.animateWithDuration(1, animations: {
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.resignFirstResponder()
        })
        searchBar.text = ""
    }
    
    //action when user's tapped the networkErroView
    @IBAction func didTapNetworkErrorView(sender: AnyObject) {
        networkRequest()
    }
    
    //colletiob view
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = filteredMovies {
            return movies.count
        }else{
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionCell", forIndexPath: indexPath) as! MovieCollectionCell
        let movie = filteredMovies![indexPath.row]
       
        let baseUrl = "https://image.tmdb.org/t/p/w342"      //movies' base url
        if let posterPath = movie["poster_path"] as! String? {
            let imageUrl = NSURL(string: baseUrl + posterPath)  //combine base url + image specific address
            cell.collectionPosterView.setImageWithURL(imageUrl!)  //display movie's image to MovieCell's posterView
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("swapSegue", sender: self.collectionView.cellForItemAtIndexPath(indexPath))
    }
    
    //action for sawpping betweens views
    @IBAction func didSwap(sender: AnyObject) {
        
        var fromView: UIView!
        var toView: UIView!
        
        //check present view and prepare fromView and toView
        if self.tableView?.superview == self.view {
            (fromView, toView) = (self.tableView, self.collectionView)
            currentcollectionView = true
            currentTableView = false
        } else {
            (fromView, toView) = (self.collectionView, self.tableView)
            currentcollectionView = false
            currentTableView = true
        }
        
        toView?.frame = fromView.frame
        UIView.transitionFromView(fromView, toView: toView,
            duration: 0.4, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
        
        //set the toggle image icon of the fromView/toView
        if fromView == tableView {
            swapButton.setImage( UIImage(named: "tableViewPic"), forState: .Normal )
        } else {
            swapButton.setImage( UIImage(named: "collectionViewPic"), forState: .Normal )
        }
    }
    
    //Customizing the appearance of navigation bar
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orangeColor()]
    }
    
}
