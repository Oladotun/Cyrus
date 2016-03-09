//
//  CollectionTwitterViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 3/3/16.
//  Copyright (c) 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Accounts
import Social

class CollectionTwitterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var stringCollection: UICollectionView!
    let reuseIdentifier = "cell"
    
    var topics = [String]()
    var uselessTopicsArray = [String]()
    
    @IBOutlet weak var unwantedTopics: UILabel!
    
    let account = ACAccountStore()
    var twitterAccount=ACAccount()
    var userFriends = Int()
    var userCollected =  [AnyObject]()
    var userToFollower = Dictionary<String, Int>()
    var userToList = [String : [String]]()
    let stopWords = ["new","social","liked","tweet","people","list","twitter","boss","dick","shit","fuck","link","facebook","friend","celeb","my","feed","influencer","racist","all"]
    var topicToUser = [String:Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        topics = ["Pain","Miserable","Expected Everytime you", "begin greatness"]
        stringCollection.allowsMultipleSelection = true
        self.userLookUp()
        self.unwantedTopics.text = "label"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.topics.count
    }
    
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return 2
//    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionTwitterCollectionViewCell
        
        cell.userTopic.text = topics[indexPath.item]
        cell.userTopic.sizeToFit()
        cell.backgroundColor = UIColor.blueColor()
        

        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        print("You unselected \(indexPath.item)")
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionTwitterCollectionViewCell
        
//        println(cell.selected)
        
//        if(cell.selected) {
//            
//            uselessTopicsArray = uselessTopicsArray.filter( {$0 != self.topics[indexPath.item]})
//            updateLabel()
////            unwantedTopics.text = ",".join(uselessTopicsArray)
//            
//            //            (topics[indexPath.item])
//            
//        }
        
        if (uselessTopicsArray.contains(topics[indexPath.item])) {
            uselessTopicsArray = uselessTopicsArray.filter( {$0 != self.topics[indexPath.item]})
            updateLabel()
            
        }
        
        
         cell.backgroundColor = UIColor.blueColor()
        
       
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("You selected \(indexPath.item)")
        
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionTwitterCollectionViewCell
        cell.backgroundColor = UIColor.redColor()
        
        print("curr cell selected: \(cell.selected)")
        
       
        
            
            if (!uselessTopicsArray.contains(topics[indexPath.item])) {
                uselessTopicsArray.append(topics[indexPath.item])
                updateLabel()
                
            }
            
            
//            unwantedTopics.text = ",".join(uselessTopicsArray)
            
       
        
    }
    
    
    func updateLabel() {
        print("Updated label")
        dispatch_async(dispatch_get_main_queue(), {
            self.unwantedTopics.text =
                (self.uselessTopicsArray.joinWithSeparator(","))
        })
    }
    
   
//    // change background color when user touches cell
//    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
//        let cell = collectionView.cellForItemAtIndexPath(indexPath)
//        cell?.backgroundColor = UIColor.redColor()
//    }
//    
//    // change background color back when user releases touch
//    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
//        let cell = collectionView.cellForItemAtIndexPath(indexPath)
//        cell?.backgroundColor = UIColor.blueColor()
//    }
    
    
//    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//            
//            let image =  UILabel(
//            return image!.size
//    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // Twitter Connection
    
    func userLookUp() {
        
        let accountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        print("In Connect To Twiiter")
        
        account.requestAccessToAccountsWithType(accountType, options: nil,
            completion: {(success:Bool, error:NSError!) -> Void in
                
                print("In Completion Mode")
                print(success)
                
                if success {
                    let arrayOfAccounts = self.account.accountsWithAccountType(accountType)
                    
                    if arrayOfAccounts.count > 0 {
                        
                        self.twitterAccount = arrayOfAccounts.last as! ACAccount
                        let requestURL = NSURL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")
                        
                        let postRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: requestURL, parameters: nil)
                        postRequest.account = self.twitterAccount
                        
                        postRequest.performRequestWithHandler(
                            {(responseData:NSData!, urlResponse: NSHTTPURLResponse!, error:NSError!) -> Void in
                                
                                
                                do {
                                    
                                    let userInfoDictionary = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableLeaves)
                                    self.userFriends = userInfoDictionary["friends_count"] as! Int
                                    print(self.userFriends)
                                    if (self.userFriends > 200) {
                                        // TODO Visit more pages in future
                                        self.userFriends = 200
                                    } else if (self.userFriends < 2) {
                                        
                                        print("Please follow someone you are interested in on twitter")
                                        // TODO Check the users list membership
                                        
                                    } else {
                                        self.getUserInfo()
                                    }
                                    
                                } catch {
                                    print(error)
                                }
                               
                                
                                
                        })
                        
                        
                    } else {
                        print("No account to access")
                    }
                    
                } else {
          print("Could not access")
                }
        })
        
    }
    
    
    // Get the List of User presents
    
    func getUserInfo() {
        
        let requestURL = NSURL(string: "https://api.twitter.com/1.1/friends/list.json")
        
        
        let parameters = ["trim_user": "1", "count" : String(self.userFriends)]
        let postRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: requestURL, parameters: parameters)
        
        postRequest.account = self.twitterAccount
        
        postRequest.performRequestWithHandler(
            { (responseData:NSData!, urlResponse: NSHTTPURLResponse!, error:NSError!) -> Void in
                
                
                do {
                    let dataSourceDictionary = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableLeaves)
                    
                    self.userCollected =  dataSourceDictionary["users"] as! [(AnyObject)]
                    self.sortUserByUserCount()
                } catch {
                    print(error)
                }
                
                
        })
    }
    
    func sortUserByUserCount() {
        
        for user in self.userCollected {
            let protected = user["protected"] as! Bool
            
            if protected == false {
                let userName = user["screen_name"] as! String
                let followerCount = user["followers_count"] as! Int
                userToFollower[userName] = followerCount
            }
            
        }
        
        var sortedArray = userToFollower.sort( {$0.1 > $1.1})
        //        print("User Follower\n")
        
        print("\nUser sorted \n")
        
        if (sortedArray.count > 5) {
            sortedArray = Array(sortedArray[0..<5])
            
        }
        print(sortedArray)
        getFriendLists(sortedArray)
        
    }
    
    
    func getFriendLists(input:[(String,Int)]) {
        
        let requestURL = NSURL(string: "https://api.twitter.com/1.1/lists/memberships.json")
        let dispatch_group = dispatch_group_create()
        
        //        for info in input {
        let info = input[0]
        print(info.0)
        
        let parameters = ["screen_name":info.0,"trim_user": "1", "count" : "300"]
        let postRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: requestURL, parameters: parameters as [NSObject : AnyObject])
        postRequest.account = self.twitterAccount
        
        dispatch_group_enter(dispatch_group)
        
        postRequest.performRequestWithHandler(
            { (responseData:NSData!, urlResponse: NSHTTPURLResponse!, error:NSError!) -> Void in
                
                
                do {
                    
                    let dataSourceDictionary = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableLeaves)
                    
                    let collected = dataSourceDictionary["lists"] as! [(AnyObject)]
                    var listName = [String]()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        for list in collected {
                            let currList = list as! NSDictionary
                            listName.append((currList.objectForKey("name") as? String)!)
                            
                        }
                        
                        
                        self.userToList[String(info.0)] = listName
                        
                        dispatch_group_leave(dispatch_group)
                        
                        
                    })
                    
                } catch {
                    print(error)
                }
                
                
                
                
        })
        
        
        //        }
        
        
        dispatch_group_notify(dispatch_group, dispatch_get_main_queue()) {
            
            print("Result")
            self.getTopicFromUserLists()
            
            
        }
        
    }
    
    
    
    func getTopicFromUserLists() {
        
        let userList = userToList.values
        for topics in userList {
            
            for topic in topics {
                var currTopic = topic
                if (!checkTopic(&currTopic)) {
                    
                    if(topicToUser[currTopic] == nil) {
                        topicToUser[currTopic] = 1
                    } else {
                        topicToUser[currTopic] = topicToUser[currTopic]! + 1
                    }
                    
                }
            }
            
        }
        let sortedArray = topicToUser.sort({$0.1 > $1.1})
        //        println(sortedArray)
        
        var imporTantTopics = [(String,Int)]()
        
        if (sortedArray.count > 30){
            imporTantTopics = Array(sortedArray[0..<30])
            
        } else {
            imporTantTopics = sortedArray
        }
        
        
        
        
        
        
        if(imporTantTopics.count > 0) {
            
            imporTantTopics.sortInPlace({ (s1:(String,Int), s2:(String,Int)) -> Bool in return (s1.0).length < (s2.0).length})
            self.topics = [String]()
            for topic in imporTantTopics {
                topics.append(topic.0)
                
            }
            
            print(topics)
            
            
           
                
            dispatch_async(dispatch_get_main_queue(), {
                self.stringCollection.reloadData()
            })
            

            
            
        }
        
        
        
        
    }

    
    
    
    func checkTopic(inout currWord:String) -> Bool {
        
        var wordToChange = currWord
        let unsafeChars = NSCharacterSet.alphanumericCharacterSet().invertedSet
        wordToChange = (wordToChange.componentsSeparatedByCharactersInSet(unsafeChars)).joinWithSeparator(" ")
        
        
        
        if currWord.length < 3 {
            return true
            
        }
        
        // Check to make sure the first Character is a digit, do not insert as an interest if true
       // var firstChar = Array(arrayLiteral: currWord)[0]
        let s = currWord.unicodeScalars
        let uni = s[s.startIndex]
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        let isADigit = digits.longCharacterIsMember(uni.value)
        
        if(isADigit) {
            return true
        }
        
        
        for word in stopWords {
            
            if (wordToChange.length > word.length ) {
                
                if wordToChange.lowercaseString.rangeOfString(word) != nil {
                    
                    return true
                }
            } else if (word.length == wordToChange.length) {
                
                if(word.caseInsensitiveCompare(wordToChange) == NSComparisonResult.OrderedSame) {
                    return true
                }
            }
            
        }
        
        
        let splitWord = wordToChange.componentsSeparatedByString(" ")
        
        if (splitWord.count > 3) {
            return true
        }
        
        
        var wordSentence = [String]()
        
        for word in splitWord {
            wordSentence.append(word.lowercaseString.capitalizeFirst.trim())
        }
        
        currWord = (wordSentence.joinWithSeparator(" "))
        currWord = currWord.trim()
        
        if (currWord.isEmpty) {
            return true
        }
        return false
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationVC = segue.destinationViewController as! HomePageViewController
        
        destinationVC.interests = topics
        
        
    }
    
    

}

class Topic {
    var topic: String!
    var selected: Bool!
}

// Sentence Case String
extension String {
    
    var capitalizeFirst: String {
        if isEmpty { return "" }
        var result = self
        result.replaceRange(startIndex...startIndex, with: String(self[startIndex]).uppercaseString)
        return result
    }
    
    func trim() -> String
    {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    var length: Int {
        return characters.count
    }
    
}




