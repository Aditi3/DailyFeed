//
//  NewsSourceViewController.swift
//  DailyFeed
//
//  Created by TrianzDev on 29/12/16.
//  Copyright © 2016 trianz. All rights reserved.
//

import UIKit

class NewsSourceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    //MARK: IBOutlets
    @IBOutlet weak var sourceTableView: UITableView!
    
    //MARK: Variable declaration
    var sourceItems = [DailySourceModel]()
    
    var filteredSourceItems = [DailySourceModel]()
    
    var selectedItem = DailySourceModel?()
    
    var resultsSearchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.dimsBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.placeholder = "Search Sources..."
        controller.searchBar.tintColor = UIColor.blackColor()
        controller.searchBar.searchBarStyle = .Minimal
        controller.searchBar.sizeToFit()
        return controller
    }()
    
    let spinningActivityIndicator = TSActivityIndicator()
    
    let container = UIView()
    
    let refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.backgroundColor = UIColor.blackColor()
        refresh.tintColor = UIColor.whiteColor()
        return refresh
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup UI
        setupUI()
        
        //Populate TableView Data
        loadSourceData()
        
        //setup TableView
        setupTableView()
        
    }
    
    //MARK: Setup UI
    func setupUI() {
        setupSearch()
        setupSpinner()
    }
    
    //MARK: Setup SearchBar
    func setupSearch() {
        self.resultsSearchController.searchResultsUpdater = self
        self.sourceTableView.tableHeaderView = resultsSearchController.searchBar
    }
    
    //MARK: Setup TableView
    func setupTableView() {
        self.sourceTableView.addSubview(refreshControl)
        self.refreshControl.addTarget(self, action: #selector(NewsSourceViewController.refreshData(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    //MARK: Setup Spinner
    func setupSpinner() {
        spinningActivityIndicator.setupTSActivityIndicator(container)
    }
    
    //MARK: refresh news Source data
    func refreshData(sender: UIRefreshControl) {
        loadSourceData()
    }
    
    //MARK: Load data from network
    func loadSourceData() {
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        DailySourceModel.getNewsSource { (newsItem, error) in
            
            
            guard error == nil, let news = newsItem else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshControl.endRefreshing()
                    self.spinningActivityIndicator.stopAnimating()
                    self.container.removeFromSuperview()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    self.showError(error?.localizedDescription ?? "", message: "") { (completed) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
                return
            }
            
            self.sourceItems = news
            dispatch_async(dispatch_get_main_queue(), {
                self.refreshControl.endRefreshing()
                self.sourceTableView.reloadData()
                self.spinningActivityIndicator.stopAnimating()
                self.container.removeFromSuperview()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            })
        }
    }
    
    //MARK: TableView Delegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultsSearchController.active {
            return self.filteredSourceItems.count
        }
        else {
            return self.sourceItems.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SourceCell", forIndexPath: indexPath)
        
        if self.resultsSearchController.active {
            cell.textLabel?.text = filteredSourceItems[indexPath.row].name
        }
        else {
            cell.textLabel?.text = sourceItems[indexPath.row].name
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.resultsSearchController.active {
            self.selectedItem = filteredSourceItems[indexPath.row]
        }
        else {
            self.selectedItem = sourceItems[indexPath.row]
        }
        
        self.performSegueWithIdentifier("sourceUnwindSegue", sender: self)
    }
    
    //MARK: SearchBar Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        filteredSourceItems.removeAll(keepCapacity: false)
        
        if let searchString = searchController.searchBar.text {
            let searchResults = sourceItems.filter { $0.name.lowercaseString.containsString(searchString.lowercaseString) }
            filteredSourceItems = searchResults
            
            self.sourceTableView.reloadData()
        }
    }
}
