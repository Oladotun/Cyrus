//
//  TwitterApiViewController.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 2/27/16.
//  Copyright (c) 2016 Dotun Opasina. All rights reserved.
//



import UIKit
import Social
import Accounts
class TwitterApiViewController: UIViewController,UITableViewDataSource,UITableViewDelegate  {

    @IBOutlet weak var tweetTableView: UITableView!
    @IBOutlet weak var tweetTwoTableView: UITableView!
    @IBOutlet weak var tweetThreeTableView: UITableView!
    
    @IBOutlet weak var uselessTopics: UILabel!
    
    let account = ACAccountStore()
    var twitterAccount=ACAccount()
    var userFriends = Int()
    var userToList = [String : [String]]()
    let stopWords = ["new","social","liked","tweet","people","list","twitter","boss","dick","shit","fuck","link","facebook","friend","celeb","my","feed","influencer","racist","all"]
    var userCollected =  [AnyObject]()
    var userToFollower = Dictionary<String, Int>()
    var topicToUser = [String:Int]()
    
    var tableViewData = [Topic]()
    var tableViewTwoData = [Topic]()
    var tableViewThreeData = [Topic]()
    
    var uselessTopicsArray = [String]()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.userLookUp()
        
        tweetTableView.dataSource = self
        tweetTableView.delegate = self
        tweetTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell1")
        tweetTableView.allowsMultipleSelection = true
        
        
        tweetTwoTableView.dataSource = self
        tweetTwoTableView.delegate = self
        tweetTwoTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell2")
        tweetTwoTableView.allowsMultipleSelection = true
        
        tweetThreeTableView.dataSource = self
        tweetThreeTableView.delegate = self
        tweetThreeTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell3")
        tweetThreeTableView.allowsMultipleSelection = true
        
         uselessTopics.text = ""
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        
        var count: Int?
        if tableView == self.tweetTableView {
            
            count = tableViewData.count
            
        } else if tableView == self.tweetTwoTableView {
//            print("Second Table called")
            count = tableViewTwoData.count
        } else if tableView == self.tweetThreeTableView {
            count = tableViewThreeData.count
        }
        
        
        return count!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell?
        
        if tableView == self.tweetTableView {
            cell = tweetTableView.dequeueReusableCellWithIdentifier("Cell1") as? UITableViewCell
            let row = indexPath.row
            cell!.textLabel!.text = tableViewData[row].topic
            cell!.selected = tableViewData[row].selected
            
            if(cell!.selected) {
             cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
             tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            } else {
                cell!.accessoryType = UITableViewCellAccessoryType.None
            }
            
           
            
            
        }
        
        if tableView == self.tweetTwoTableView {
            cell = tweetTwoTableView.dequeueReusableCellWithIdentifier("Cell2") as? UITableViewCell
            let row = indexPath.row
            
            cell!.textLabel!.text = tableViewTwoData[row].topic
            cell!.selected = tableViewTwoData[row].selected
            
            
            if(cell!.selected) {
                cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            } else {
                cell!.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        if tableView == self.tweetThreeTableView {
            cell = tweetThreeTableView.dequeueReusableCellWithIdentifier("Cell3") as? UITableViewCell
            let row = indexPath.row
            
            cell!.textLabel!.text = tableViewThreeData[row].topic
            cell!.selected = tableViewThreeData[row].selected
            
            
            if(cell!.selected) {
                cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            } else {
                cell!.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        
        if uselessTopicsArray.count > 0 {
            var allUselessWords = ",".join(uselessTopicsArray)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.uselessTopics.text = allUselessWords
            })
        } else {
            uselessTopics.text = ""
        }
        

        return cell!
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell:UITableViewCell?
        
       
        if tableView == self.tweetTableView {
            cell = tweetTableView.dequeueReusableCellWithIdentifier("Cell1") as? UITableViewCell
            let row = indexPath.row
            
             println("Selection called")
            cell!.selected = tableViewData[row].selected
//            
            if (!cell!.selected) {
                cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
//                cell!.selected = false
                tableViewData[row].selected = true
                
                uselessTopicsArray = uselessTopicsArray.filter( {$0 != self.tableViewData[row].topic})
                tableView.reloadData()
                
            }
            
        }
        
        if tableView == self.tweetTwoTableView {
            cell = tweetTwoTableView.dequeueReusableCellWithIdentifier("Cell2") as? UITableViewCell
            let row = indexPath.row
            
            println("Selection called")
            cell!.selected = tableViewTwoData[row].selected
            //
            if (!cell!.selected) {
                cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
                tableViewTwoData[row].selected = true
                uselessTopicsArray = uselessTopicsArray.filter( {$0 != self.tableViewTwoData[row].topic})
                tableView.reloadData()
                
            }

        }
        
        if tableView == self.tweetThreeTableView {
            cell = tweetThreeTableView.dequeueReusableCellWithIdentifier("Cell3") as? UITableViewCell
            
            let row = indexPath.row
            
            println("Selection called for table 3")
            cell!.selected = tableViewThreeData[row].selected
            println( "Is TableViewThree Selected " + String( stringInterpolationSegment: tableViewThreeData[row].selected))
            //
            if (!cell!.selected) {
                cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
                tableViewThreeData[row].selected = true
                uselessTopicsArray = uselessTopicsArray.filter( {$0 != self.tableViewThreeData[row].topic})
                tableView.reloadData()
                
            }

        }
        
//        tableView.reloadData()
        

    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var cell:UITableViewCell?
        
        
        if tableView == self.tweetTableView {
            cell = tweetTableView.dequeueReusableCellWithIdentifier("Cell1") as? UITableViewCell
            let row = indexPath.row
            
            println("DeSelection called")
            //            cell!.textLabel!.text = tableViewData[row]
//            println(
            println("Current cell Value: " + String(stringInterpolationSegment: cell!.selected))
            cell!.selected = tableViewData[row].selected
            println("Current Topic: " + String(stringInterpolationSegment: tableViewData[row].topic))
            println("Current Row Value: " + String(stringInterpolationSegment: tableViewData[row].selected))
            //
            if (cell!.selected) {
                cell!.accessoryType = UITableViewCellAccessoryType.None
                 cell!.selected = false
                tableViewData[row].selected = false
                
                uselessTopicsArray.append(tableViewData[row].topic)
                
                tableView.reloadData()
                
            }
            
        }
        
        
        if tableView == self.tweetTwoTableView {
            cell = tweetTwoTableView.dequeueReusableCellWithIdentifier("Cell2") as? UITableViewCell
            let row = indexPath.row
            
            println("DeSelection called")
            
            println("Current cell Value: " + String(stringInterpolationSegment: cell!.selected))
            cell!.selected = tableViewTwoData[row].selected
            println("Current Topic: " + String(stringInterpolationSegment: tableViewTwoData[row].topic))
            println("Current Row Value: " + String(stringInterpolationSegment: tableViewTwoData[row].selected))
            //
            if (cell!.selected) {
                cell!.accessoryType = UITableViewCellAccessoryType.None
                cell!.selected = false
                tableViewTwoData[row].selected = false
                
                uselessTopicsArray.append(tableViewTwoData[row].topic)
                
                tableView.reloadData()
                
            }
            
        }
        
        if tableView == self.tweetThreeTableView {
            cell = tweetThreeTableView.dequeueReusableCellWithIdentifier("Cell3") as? UITableViewCell
            let row = indexPath.row
            
            println("DeSelection called")
            
            println("Current cell Value: " + String(stringInterpolationSegment: cell!.selected))
            cell!.selected = tableViewThreeData[row].selected
            println("Current Topic: " + String(stringInterpolationSegment: tableViewThreeData[row].topic))
            println("Current Row Value: " + String(stringInterpolationSegment: tableViewThreeData[row].selected))
            //
            if (cell!.selected) {
                cell!.accessoryType = UITableViewCellAccessoryType.None
                cell!.selected = false
                tableViewThreeData[row].selected = false
                
                uselessTopicsArray.append(tableViewThreeData[row].topic)
                
                tableView.reloadData()
                
            }
            
        }
        
        
        
        
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
        
        var sortedArray = sorted(userToFollower, {$0.1 > $1.1})
        //        print("User Follower\n")
        
        println("\nUser sorted \n")
        
        if (sortedArray.count > 5) {
            sortedArray = Array(sortedArray[0..<5])
            
        }
        println(sortedArray)
        getFriendLists(sortedArray)
        
    }
    
    func getFriendLists(input:[(String,Int)]) {
        
        let requestURL = NSURL(string: "https://api.twitter.com/1.1/lists/memberships.json")
        let dispatch_group = dispatch_group_create()
        
//        for info in input {
            var info = input[0]
            println(info.0)
            
            let parameters = ["screen_name":info.0,"trim_user": "1", "count" : "300"]
            let postRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: requestURL, parameters: parameters as [NSObject : AnyObject])
            postRequest.account = self.twitterAccount
            
            dispatch_group_enter(dispatch_group)
            
            postRequest.performRequestWithHandler(
                { (responseData:NSData!, urlResponse: NSHTTPURLResponse!, error:NSError!) -> Void in
                    
                    
                    var err: NSError?
                    let dataSourceDictionary = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableLeaves, error: &err) as!  NSDictionary
                    
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
                    
                    
            })
            
            
//        }
        
        
        dispatch_group_notify(dispatch_group, dispatch_get_main_queue()) {
            
            println("Result")
            self.getTopicFromUserLists()
            
        }
        
    }
    
    func checkTopic(inout currWord:String) -> Bool {
        
        var wordToChange = currWord
        let unsafeChars = NSCharacterSet.alphanumericCharacterSet().invertedSet
        wordToChange = " ".join(wordToChange.componentsSeparatedByCharactersInSet(unsafeChars))
        
        
        
        if count(currWord) < 3 {
            return true
            
        }
        
        // Check to make sure the first Character is a digit, do not insert as an interest if true
        var firstChar = Array(currWord)[0]
        let s = currWord.unicodeScalars
        let uni = s[s.startIndex]
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        let isADigit = digits.longCharacterIsMember(uni.value)
        
        if(isADigit) {
            return true
        }
        
        
        for word in stopWords {
            
            if (count(wordToChange) > count(word) ) {
                
                if wordToChange.lowercaseString.rangeOfString(word) != nil {
                    
                    return true
                }
            } else if (count(word) == count(wordToChange)) {
                
                if(word.caseInsensitiveCompare(wordToChange) == NSComparisonResult.OrderedSame) {
                    return true
                }
            }
            
        }
        
        
        var splitWord = wordToChange.componentsSeparatedByString(" ")
        
        if (splitWord.count > 3) {
            return true
        }
        
        
        var wordSentence = [String]()
        
        for word in splitWord {
            wordSentence.append(word.lowercaseString.capitalizeFirst.trim())
        }
        
        currWord = " ".join(wordSentence)
        currWord = currWord.trim()
        
        if (currWord.isEmpty) {
            return true
        }
         return false
        
    }
    
    func getTopicFromUserLists() {
        
        var userList = userToList.values
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
        let sortedArray = sorted(topicToUser, {$0.1 > $1.1})
        //        println(sortedArray)
        
        var imporTantTopics = [(String,Int)]()
        
        if (sortedArray.count > 30){
            imporTantTopics = Array(sortedArray[0..<30])
            
        } else {
            imporTantTopics = sortedArray
        }
        
        
        
        
        
        
        if(imporTantTopics.count > 0) {
            
            imporTantTopics.sort({ (s1:(String,Int), s2:(String,Int)) -> Bool in return count(s1.0) < count(s2.0)})
            
            
            if(imporTantTopics.count <= 3) {
                
                
                for var index = 0; index < imporTantTopics.count; index++ {
                    var currTopic = imporTantTopics[index]
                    var newTopic = Topic()
                    newTopic.topic = currTopic.0
                    newTopic.selected = true
                    tableViewData.append(newTopic)
                    
                }
                
                if (tableViewData.count > 0) {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tweetTableView.reloadData()
                        
                    })
                }
                
                
                
            } else {
                
                var topicSplit = imporTantTopics.count / 3
                var midPosition = topicSplit * 2
                
                
                // Index for TableViewOne Data
                for var index = 0; index < topicSplit; index++ {
                    var currTopic = imporTantTopics[index]
                    var newTopic = Topic()
                    newTopic.topic = currTopic.0
                    newTopic.selected = true
                    tableViewData.append(newTopic)
                    
                }
                
                
                for var secInd = topicSplit; midPosition < imporTantTopics.count && secInd < midPosition; secInd++ {
                    var currTopic = imporTantTopics[secInd]
                    var newTopic = Topic()
                    newTopic.topic = currTopic.0
                    newTopic.selected = true
                    tableViewTwoData.append(newTopic)
                }
                
                
                for var thirdInd = midPosition; thirdInd < imporTantTopics.count; thirdInd++ {
                    var currTopic = imporTantTopics[thirdInd]
                    var newTopic = Topic()
                    newTopic.topic = currTopic.0
                    newTopic.selected = true
                    tableViewThreeData.append(newTopic)
                }
                //
                //        for topic in imporTantTopics {
                //            userTopics.append(topic.0)
                //        }
                
                println(tableViewData)
                println(tableViewTwoData)
                println(tableViewThreeData)
                
                if (tableViewData.count > 0) {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tweetTableView.reloadData()
                        self.tweetTwoTableView.reloadData()
                        self.tweetThreeTableView.reloadData()
                    })
                }
                
            }
            
            
            
            
        }
        
        
        
        //        if (tableViewTwoData.count > 0) {
        //            println("loading data")
        //            dispatch_async(dispatch_get_main_queue(), {
        //                self.tweetTwoTableView.reloadData()
        //            })
        //        }
        
        
        
        //        self.tweetTwoTableView.reloadData()
        
        
        
    }
    
    
    func userLookUp() {
        
        let accountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        println("In Connect To Twiiter")
        
        account.requestAccessToAccountsWithType(accountType, options: nil,
            completion: {(success:Bool, error:NSError!) -> Void in
                
                print("In Completion Mode")
                println(success)
                
                if success {
                    let arrayOfAccounts = self.account.accountsWithAccountType(accountType)
                    
                    if arrayOfAccounts.count > 0 {
                        
                        self.twitterAccount = arrayOfAccounts.last as! ACAccount
                        let requestURL = NSURL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")
                        
                        let postRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: requestURL, parameters: nil)
                        postRequest.account = self.twitterAccount
                        
                        postRequest.performRequestWithHandler(
                            {(responseData:NSData!, urlResponse: NSHTTPURLResponse!, error:NSError!) -> Void in
                                var err:NSError?
                                let userInfoDictionary = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableLeaves, error: &err) as!  NSDictionary
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
                                
                        })
                        
                        
                    } else {
                        println("No account to access")
                    }
                    
                } else {
                    println("Could not access")
                }
        })
        
    }
    
    
    func getUserInfo() {
        
        let requestURL = NSURL(string: "https://api.twitter.com/1.1/friends/list.json")
        
        
        let parameters = ["trim_user": "1", "count" : String(self.userFriends)]
        let postRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: requestURL, parameters: parameters)
        
        postRequest.account = self.twitterAccount
        
        postRequest.performRequestWithHandler(
            { (responseData:NSData!, urlResponse: NSHTTPURLResponse!, error:NSError!) -> Void in
                var err: NSError?
                let dataSourceDictionary = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableLeaves, error: &err) as!  NSDictionary
                
                self.userCollected =  dataSourceDictionary["users"] as! [(AnyObject)]
                self.sortUserByUserCount()
                
                if self.userCollected.count != 0 {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tweetTableView.reloadData()
                    })
                }
                
        })
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
    
}
