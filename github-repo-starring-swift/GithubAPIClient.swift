//
//  GithubAPIClient.swift
//  github-repo-starring-swift
//
//  Created by Haaris Muneer on 6/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class GithubAPIClient {
    
    class func getRepositoriesWithCompletion(completion: (NSArray) -> ()) {
        let urlString = "\(githubAPIURL)/repositories?client_id=\(githubClientID)&client_secret=\(githubClientSecret)"
        let url = NSURL(string: urlString)
        let session = NSURLSession.sharedSession()
        
        guard let unwrappedURL = url else { fatalError("Invalid URL") }
        let task = session.dataTaskWithURL(unwrappedURL) { (data, response, error) in
            guard let data = data else { fatalError("Unable to get data \(error?.localizedDescription)") }
            
            if let responseArray = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSArray {
                if let responseArray = responseArray {
                    completion(responseArray)
                }
            }
        }
        task.resume()
    }
  
  class func checkIfRepositoryIsStarred(fullName: String, completion: Bool -> Void) {
    let urlString = "\(githubAPIURL)/user/starred/\(fullName)?access_token=\(githubAccessToken)"
    
    guard let url = NSURL(string: urlString) else { return }
    
    let session = NSURLSession.sharedSession()
    
    let task = session.dataTaskWithURL(url) { (data, response, error) in
      
      let httpResponse = response as! NSHTTPURLResponse
      
      let isStarred: Bool = httpResponse.statusCode == 204
      
      completion(isStarred)
      
    }
    task.resume()
  }
  
  /**
   PUT /user/starred/:owner/:repo
   Note that you'll need to set Content-Length to zero when calling out to this endpoint.
  */
  class func starRepository(fullName: String, completion: ()->() ) {
    guard let URL = NSURL(string:"\(githubAPIURL)/user/starred/\(fullName)") else { fatalError("Invalid URL") }
    let request = NSMutableURLRequest(URL: URL)
    request.HTTPMethod = "PUT"
    request.addValue("token \(githubAccessToken)", forHTTPHeaderField: "Authorization")
    request.addValue("0", forHTTPHeaderField: "Content-Length")
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { (data, response, error) in
      let httpResponse  = response as! NSHTTPURLResponse
      if httpResponse.statusCode == 204 { print("Successfully starred repo: \(fullName)") }
      completion()
    }
    task.resume()
  }
  
  class func unstarRepository(fullName: String, completion: ()->() ) {
    guard let URL = NSURL(string:"\(githubAPIURL)/user/starred/\(fullName)") else { fatalError("Invalid URL") }
    let request = NSMutableURLRequest(URL: URL)
    request.HTTPMethod = "DELETE"
    request.addValue("token \(githubAccessToken)", forHTTPHeaderField: "Authorization")
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { (data, response, error) in
      let httpResponse  = response as! NSHTTPURLResponse
      if httpResponse.statusCode == 204 { print("Successfully unstarred repo: \(fullName)") }
      completion()
    }
    task.resume()
  }
  
  class func toggleStarStatusForRepository(repository: String, completion: (Bool)->() ) {
    // Check to see if this repository is starred
    self.checkIfRepositoryIsStarred(repository) { (isStarred) in
      if isStarred {
        // Unstar the repo
        self.unstarRepository(repository, completion: { 
          completion(false)
        })
      }
      else {
        // star the repo
        self.starRepository(repository, completion: { 
          completion(true)
        })
      }
    }
  }
  
    
}

