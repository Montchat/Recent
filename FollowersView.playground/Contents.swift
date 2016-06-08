
//  Created by Joe E. on 5/9/16.
//  Copyright © 2016 Montchat. All rights reserved.

import UIKit
import Parse // obviously you will get an error here because we can't currently import Parse within playgrounds
import Bolts // same as statement above


//this is the majority of the code associated for a view within

typealias User = ([String],[String]) // associae a User with a userID and username

class FollowersView: UIView {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tabBar: UITabBar!
    
    var userFollowing:(User) = ([],[]) { didSet { tableView.reloadData() } }
    var userFollowers:(User) = ([],[]) { didSet { tableView.reloadData() } }
    var userBlocked:(User) = ([],[]) { didSet { tableView.reloadData() } }
    
    @IBAction func backPressed(sender: AnyObject) {
        removeView(view: self)
        
    }
    
}

extension FollowersView : UITabBarDelegate {
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        UIView.animateWithDuration(0.165, animations: { self.label.alpha = 0 })
            
        { (Bool) in
            
            self.label.text = item.title
            self.tableView.reloadData()
            UIView.animateWithDuration(0.33, animations: { self.label.alpha = 1 } )
            
        }
        
    }
    
}


extension UIView {

    // associated with the back button. when you hit the button, it animates away the view and completly removes it from the superview. this is obviously important functionality that should not be limited to just a "Followers View" and can be implemented with any view. so we has extended out the functionality to anything that is a class of UIView
    func removeView(view view:UIView) {
        UIView.animateWithDuration(0.33, animations: {
            view.alpha = 0
        }) { (Bool) in
            view.removeFromSuperview()
        }
        
    }
    
}

extension FollowersView {
    
    func getUserFollowersFollowingBlockedInBackground(followingReturned:(([String],[String])) -> (), followersReturned:(([String],[String])) -> (), blockedReturned: ([String],[String]) -> () ) {
        
        //these are closures that return data associated with "Following," "Follower," and Blocked keys. It queries for all of these and then will update the UI based on what gets returned. You can use this to update the
        
        //get associated objectIds with the use
        _ = queryForUserDataArrayWithKeyAndAddToArray(key: "following") { (data) in
            let username = data.0
            let objectID = data.1
            
            followingReturned((username, objectID))
        }
        
        _ = queryForUserDataArrayWithKeyAndAddToArray(key: "followers") { (data) in
            let username = data.0
            let objectID = data.1
            
            followersReturned((username, objectID))
            
        }
        
        _ = queryForUserDataArrayWithKeyAndAddToArray(key: "blockedUsers") { (data) in
            let username = data.0
            let objectID = data.1
            
            blockedReturned((username, objectID))
            
        }
        
    }
    
}

extension FollowersView {
    
    func queryForUserDataArrayWithKeyAndAddToArray(key key:String, returnedArrays:(([String],[String])) -> ()) {
        
        //querys for the data associated with the key based on what we want on Parse. gets all of the current users data.
        
        var usernameArray:[String] = []  ; var objectIDArray:[String] = []
        
        guard let currentUser = PFUser.currentUser() else { return }
        
        guard let key = currentUser[key] as? [String] else { return }
        
        let query = PFUser.query()?.whereKey("objectId", containedIn: key)
        
        let activityIndicator = UIActivityIndicatorView(frame: self.frame)
        
        self.addSubview(activityIndicator)
        
        query?.findObjectsInBackgroundWithBlock({ (users, error) -> Void
            in if error != nil { print(error) }
            
            dispatch_async(dispatch_get_main_queue(), { activityIndicator.startAnimating()
            })
            
            guard let users = users as? [PFUser] else { return }
            
            for user in users {
                
                guard let username = user.username else { return } ; guard let objectId = user.objectId else { return }
                usernameArray.append(username) ; objectIDArray.append(objectId)
                
            }
            
            returnedArrays((usernameArray,objectIDArray))
            
            dispatch_async(dispatch_get_main_queue(), { activityIndicator.stopAnimating() })
            
        })
        
    }
    
}

extension UIViewController { // we extend out UIViewController to be able to initalize the followers view
    
    func initalizeFollowers() {
        
        guard let followers = FollowersView.loadFromNibNamed("FollowersView") as? FollowersView else { return } //loaded from a nib
        followers.frame = view.frame // takes up the whole frame of the view controller
        followers.userInteractionEnabled = true
        
        for view in followers.subviews { view.userInteractionEnabled = true } // just to double check and provide user interaction within each view.
        
        followers.alpha = 0 ; followers.tag = 7
        
        addAnimateGestureRecognizerToView(followers.backView) // add
        view.addSubview(followers)
        
        initalizeFollowersTabBar(tabBar: followers.tabBar, delegate: followers) // intalize a tab bar at the bottom of the view
        
        let tableView = followers.tableView
        initalizeFollowersTableView(tableView, delegate: followers) // initalize the tabledView
        
        followers.getUserFollowersFollowingBlockedInBackground( // get our followers
            
            { (usernames, objectIDs) in followers.userFollowing = (usernames, objectIDs)
                
            }, followersReturned: { (usernames, objectIDs) in followers.userFollowers = (usernames, objectIDs)
                
            })
            
        { (usernames, objectIDs) in followers.userBlocked = (usernames, objectIDs) }
        
        UIView.animateWithDuration(0.33) { followers.alpha = 1 } // animate the view
        
    }
    
}


extension UIViewController {
    
    func initalizeFollowersTabBar(tabBar tabBar:UITabBar, delegate: UITabBarDelegate) {
        
        //customized our tab bar a little bit
        
        tabBar.shadowImage = UIImage()
        tabBar.tintColor = UIColor(red: 0.21, green: 0.21, blue: 0.21, alpha: 1)
        tabBar.backgroundColor = UIColor.clearColor()
        tabBar.backgroundImage = UIImage()
        tabBar.barTintColor = UIColor(white: 1, alpha: 1)
        
        tabBar.delegate = delegate
        
        guard let items = tabBar.items else { return }
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor(red: 0.21, green: 0.21, blue: 0.21, alpha: 1) ] // make sure the tab bar text matches our colors above
        for item in items {
            item.setTitleTextAttributes( titleDict as? [String : AnyObject], forState: .Normal)
        }
        
        let following = items[0]
        let followersItem = items[1]
        let blocked = items[2]
        
        //images are obviously not in this file
        
        guard let followingImg = UIImage(named: "Following") else { return }
        guard let followersImg = UIImage(named: "Followers") else { return }
        guard let blockedImg = UIImage(named: "Blocked") else { return }
        
        following.image = followingImg.imageWithRenderingMode(.AlwaysOriginal)
        followersItem.image = followersImg.imageWithRenderingMode(.AlwaysOriginal)
        blocked.image = blockedImg.imageWithRenderingMode(.AlwaysOriginal)
        
        tabBar.selectedItem = following
        
    }
    
    func initalizeFollowersTableView(tableView:UITableView, delegate:FollowersView) {
        
        tableView.delegate = delegate  ; tableView.dataSource = delegate
        tableView.layoutMargins = UIEdgeInsetsZero
        
    }
    
}