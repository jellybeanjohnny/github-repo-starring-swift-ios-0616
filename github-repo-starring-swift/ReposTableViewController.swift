//
//  ReposTableViewController.swift
//  github-repo-starring-swift
//
//  Created by Haaris Muneer on 6/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ReposTableViewController: UITableViewController {
  
  let store = ReposDataStore.sharedInstance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.accessibilityLabel = "tableView"
    self.tableView.accessibilityIdentifier = "tableView"
    
    store.getRepositoriesWithCompletion {
      NSOperationQueue.mainQueue().addOperationWithBlock({
        self.tableView.reloadData()
      })
    }
  }
  
  
  // MARK: - Table view data source
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.store.repositories.count
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("repoCell", forIndexPath: indexPath)
    
    let repository:GithubRepository = self.store.repositories[indexPath.row]
    cell.textLabel?.text = repository.fullName
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    
    guard let repoName = cell?.textLabel?.text else { return }
    
    GithubAPIClient.toggleStarStatusForRepository(repoName) { (isStarred) in
      
      let alertController = UIAlertController(title: "", message: "", preferredStyle: .Alert)
      let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
      alertController.addAction(okayAction)
     
      dispatch_async(dispatch_get_main_queue(), { 
        if isStarred {
          alertController.title = "You just starred \(repoName)"
          alertController.accessibilityLabel = "You just starred \(repoName)"
        }
        else {
          alertController.title = "You just unstarred \(repoName)"
          alertController.accessibilityLabel = "You just unstarred \(repoName)"
        }
        self.presentViewController(alertController, animated: true, completion: nil)
      })
    }
  }
  
}
