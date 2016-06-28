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
import Firebase

class CollectionTwitterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var stringCollection: UICollectionView!
    let reuseIdentifier = "cell"
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var topics:[String]!
    var uselessTopicsArray = [String]()
    
    @IBOutlet weak var unwantedTopics: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let account = ACAccountStore()
    var twitterAccount=ACAccount()
    var userFriends = Int()
    var userCollected =  [AnyObject]()
    var userToFollower = Dictionary<String, Int>()
    var userToList = [String : [String]]()
    let stopWords = ["new","social","liked","tweet","people","list","twitter","boss","dick","shit","fuck","link","facebook","friend","celeb","my","feed","influencer","racist","all","funny","follower","instagram","fav","interest","important","accounts","famous","star","media","other"]
    var topicToUser = [String:Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
       activityIndicator.startAnimating()

        // Do any additional setup after loading the view.
        stringCollection.allowsMultipleSelection = true
        self.unwantedTopics.text = "Click on interests to remove from interest list"
        nextButton.alpha = 0.0
        unwantedTopics.alpha = 0.0
        if (topics != nil){
            self.stringCollection.reloadData()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.alpha = 0.0
            self.nextButton.alpha = 1.0
        } else {
            topics = [String]()
            self.userLookUp()
        }
        
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.topics.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionTwitterCollectionViewCell
        
        cell.userTopic.text = topics[indexPath.item]
        cell.userTopic.sizeToFit()
        cell.backgroundColor = UIColor.blueColor()
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionTwitterCollectionViewCell
        
        if (uselessTopicsArray.contains(topics[indexPath.item])) {
            uselessTopicsArray = uselessTopicsArray.filter( {$0 != self.topics[indexPath.item]})
            updateLabel()
            
        }
        
        cell.backgroundColor = UIColor.blueColor()
        
       
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionTwitterCollectionViewCell
        cell.backgroundColor = UIColor.redColor()
        
        if (!uselessTopicsArray.contains(topics[indexPath.item])) {
            uselessTopicsArray.append(topics[indexPath.item])
            updateLabel()
            
        }
        
    }
    
    
    func updateLabel() {
        dispatch_async(dispatch_get_main_queue(), {
            self.unwantedTopics.text =
                (self.uselessTopicsArray.joinWithSeparator(","))
        })
    }
    
   

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
        
        account.requestAccessToAccountsWithType(accountType, options: nil,
            completion: {(success:Bool, error:NSError!) -> Void in
                
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
                                    
                                    if let userFriendCount = userInfoDictionary["friends_count"] as? Int {
                                        
                                        self.userFriends = userFriendCount
                                        if (self.userFriends < 2) {
                                            // TODO Check the users list membership
                                            self.alertView("Please follow more people you are interested in on Twitter so we can infer your Interests")
                                        }
                                        else {
                                            let cursor = -1
                                            self.getUserInfo(cursor)
                                        }
                                        
                                    } else {
                                        self.alertView("Could not verify account.\nPlease Go to Settings > Twitter and Re-Sign into Twitter")
                                    }
                                    
                                    
                                } catch {
                                    self.alertView("Error occured while inferring interest")
                                }
                        })
                        
                        
                    } else {
                        self.alertView("There are no Twitter accounts currently set up.\nPlease Go to Settings > Twitter and Sign into Twitter")
                    }
                    
                } else {
                    self.alertView("Could not access your Twitter Account.\nPlease Go to Settings > Twitter and authorize Cyrus")
                }
        })
        
    }
    
    
    // Get the List of User presents
    
    func getUserInfo(cursorValue:Int) {
        
        let requestURL = NSURL(string: "https://api.twitter.com/1.1/friends/list.json")
        let parameters = ["trim_user": "1", "count" : "200", "cursor": String(cursorValue)]
        let postRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: requestURL, parameters: parameters)
        
        postRequest.account = self.twitterAccount
        dispatch_async(dispatch_get_main_queue()) {
        postRequest.performRequestWithHandler(
            { (responseData:NSData!, urlResponse: NSHTTPURLResponse!, error:NSError!) -> Void in

                do {
                    let dataSourceDictionary = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableLeaves)
                    if let collUsers =  dataSourceDictionary["users"] as? [(AnyObject)] {
                        print(cursorValue)
                        
                        for i in collUsers {
                            self.userCollected.append(i)
                        }
                        print(self.userCollected.count)
                        let cursor = dataSourceDictionary[ "next_cursor" ] as! Int
                         print("next cursor \(cursor)")
                        if (cursor != 0) {
                            self.getUserInfo(cursor)
                            
                        } else {
                            if (!self.userCollected.isEmpty) {
                                self.sortUserByUserCount()
                            }
                            return
                        }
                        
                    } else {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.alertView("Error while getting users from twitter")
                        })
                        return
                    }

                } catch {
                    self.alertView("Error while getting users from twitter")
                }
            })
        }
        
    }
    
    func sortUserByUserCount() {
        
        for user in self.userCollected {
            let protected = user["protected"] as! Bool
            
            if protected == false {
                let userName = user["screen_name"] as! String
                let followerCount = user["followers_count"] as! Int
                var friendsCount = user["friends_count"] as! Int
                
                if (followerCount > 10000) {
                    
                    if (friendsCount <= 0) {
                        friendsCount = 1
                    }
                    
                    let ratio = followerCount/friendsCount
                    userToFollower[userName] = ratio
                    
                }

            }
            
        }
        
        var sortedArray = userToFollower.sort( {$0.1 > $1.1})
        let no = 15
        if (sortedArray.count > no) { // number of inviduals to infer topic from
            sortedArray = Array(sortedArray[0..<no])
            
        }
        getFriendLists(sortedArray)
        
    }
    
    
    func getFriendLists(input:[(String,Int)]) {
        
        let requestURL = NSURL(string: "https://api.twitter.com/1.1/lists/memberships.json")
        let dispatch_group = dispatch_group_create()
        var foundNil = false
        
        for info in input {
            let parameters = ["screen_name":info.0,"trim_user": "1", "count" : "300"]
            let postRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: requestURL, parameters: parameters as [NSObject : AnyObject])
            postRequest.account = self.twitterAccount
            
            dispatch_group_enter(dispatch_group)
            postRequest.performRequestWithHandler(
                { (responseData:NSData!, urlResponse: NSHTTPURLResponse!, error:NSError!) -> Void in

                    do {
                        
                        let dataSourceDictionary = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableLeaves)
                        if let collected = dataSourceDictionary["lists"] as? [(AnyObject)] {
                            var listName = [String]()
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                for list in collected {
                                    if let currList = list as? NSDictionary {
                                        listName.append((currList.objectForKey("name") as? String)!)
                                    }
                                }
                                self.userToList[String(info.0)] = listName
                            })
                            dispatch_group_leave(dispatch_group)
                        } else {
                            if (!foundNil) {
                                foundNil = true
                                
                            }
                            dispatch_group_leave(dispatch_group)
                            
                        }
 
                    } catch {
                        self.alertView("Error Occured while getting User List")
                    }
            })
      
        }
        
            dispatch_group_notify(dispatch_group, dispatch_get_main_queue()) {
            if (foundNil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.alertView("Error while getting users from twitter")
                })
               
            } else {
                self.getTopicFromUserLists()

            }
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
        var importantTopics = getImportantTopics(sortedArray)
   
        if (importantTopics.count > 0) {
            
            importantTopics.sortInPlace({ (s1:(String,Int), s2:(String,Int)) -> Bool in return (s1.0).length < (s2.0).length})
            self.topics = [String]()
            for topic in importantTopics {
                topics.append(topic.0)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.stringCollection.reloadData()
                self.activityIndicator.stopAnimating()
                self.nextButton.alpha = 1.0
                NSUserDefaults.standardUserDefaults().setObject(self.topics, forKey: "TwitterTopics")
                self.unwantedTopics.alpha = 1.0
            })
        }
 
    }
    
    func getImportantTopics(topic:[(String,Int)]) -> [(String,Int)]{
        
        var allTopic = topic
        var newTopic = [(String,Int)]()
        
        while(allTopic.count > 0 && newTopic.count < 30) {
            
            let newWord = allTopic.removeFirst()
            var wordToRemove = ""
            var wordSum = 0
            var addNew = false
            var index = 0
            
            for word in newTopic {
                // Calculate fuzziness of interest to collapse them
                if (newWord.0.score(word.0, fuzziness: 1.0) > 0.7) {
                    wordToRemove = word.0
                    if newWord.1 > word.1 {
                        
                        addNew = true
                        
                    } else {
                        addNew = false
                    }
                    
                    wordSum = newWord.1 + word.1
                    break
                    
                }
                index = index + 1
            }
            
            if (!wordToRemove.isEmpty) {
                newTopic.removeAtIndex(index)
                if (addNew) {
                    newTopic.append((newWord.0,wordSum))
                } else {
                    newTopic.append((wordToRemove,wordSum))
                }
                
                
                
            } else {
                newTopic.append(newWord)
            }
        }
        
//        print(newTopic)
        return newTopic
        
    }


    func checkTopic(inout currWord:String) -> Bool {
        
        var wordToChange = currWord
        let unsafeChars = NSCharacterSet.alphanumericCharacterSet().invertedSet
        wordToChange = (wordToChange.componentsSeparatedByCharactersInSet(unsafeChars)).joinWithSeparator(" ")

        if currWord.length < 4 {
            return true
        }
        // Check to make sure the first Character is a digit, do not insert as an interest if true
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
    
    func alertView(message:String) {
        activityIndicator.stopAnimating()
        
        let alert = UIAlertController(title:"",message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            
            alert.dismissViewControllerAnimated(true, completion: nil)
            // Remove indicator
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()
            })
        }
        
        alert.addAction(doneAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//        let destinationVC = segue.destinationViewController as! HomePageViewController
        topics = topics.filter{!uselessTopicsArray.contains($0)}
//        destinationVC.interests = topics

        let userInterests = ["interests":topics]
        
        FIRDatabase.database().referenceFromURL("https://cyrusthegreat.firebaseio.com/users/\(appDelegate.userIdentifier)/").updateChildValues(userInterests)
        
        
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
    
    func toBase64()->String{
        
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
    }
    
    func base64Decoded() -> String {
        let decodedData = NSData(base64EncodedString: self, options:NSDataBase64DecodingOptions(rawValue: 0))
        let decodedString = NSString(data: decodedData!, encoding: NSUTF8StringEncoding)
        return decodedString as! String
    }
    
    func score(word: String, fuzziness: Double? = nil) -> Double {
        // If the string is equal to the word, perfect match.
        if self == word {
            return 1
        }
        
        //if it's not a perfect match and is empty return 0
        if word.isEmpty || self.isEmpty {
            return 0
        }
        
        var
        runningScore = 0.0,
        charScore = 0.0,
        finalScore = 0.0
        
        var string = ""
        var lWord = ""
        if (self.characters.count < word.characters.count) {
            string = word
            lWord = self.lowercaseString
        } else {
            string = self
            lWord = word.lowercaseString
        }

        let lString = string.lowercaseString,
        strLength = string.characters.count

        var wordLength = lWord.characters.count,
        idxOf: String.Index!,
        startAt = lString.startIndex,
        fuzzies = 1.0,
        fuzzyFactor = 0.0,
        fuzzinessIsNil = true

        // Cache fuzzyFactor for speed increase
        if let fuzziness = fuzziness {
            fuzzyFactor = 1 - fuzziness
            fuzzinessIsNil = false
        }
        
        for i in 0 ..< wordLength {
            // Find next first case-insensitive match of word's i-th character.
            // The search in "string" begins at "startAt".
            if let range = lString.rangeOfString(
                String(lWord[lWord.startIndex.advancedBy(i)] as Character),
                options: NSStringCompareOptions.CaseInsensitiveSearch,
                range: Range<String.Index>(startAt..<lString.endIndex),
                locale: nil
                ) {
                    // start index of word's i-th character in string.
                    idxOf = range.startIndex
                    
                    if startAt == idxOf {
                        // Consecutive letter & start-of-string Bonus
                        charScore = 0.7
                    }
                    else {
                        charScore = 0.1
                        // Acronym Bonus
                        // Weighing Logic: Typing the first character of an acronym is as if you
                        // preceded it with two perfect character matches.
                        if string[idxOf.advancedBy(-1)] == " " {
                            charScore += 0.8
                        }
                    }
            }
            else {
                // Character not found.
                if fuzzinessIsNil {
                    // Fuzziness is nil. Return 0.
                    return 0
                }
                else {
                    fuzzies += fuzzyFactor
                    continue
                }
            }
            
            // Same case bonus.
            if (string[idxOf] == word[word.startIndex.advancedBy(i)]) {
                charScore += 0.1
            }
            
            // Update scores and startAt position for next round of indexOf
            runningScore += charScore
            startAt = idxOf.advancedBy(1)
        }
        
        // Reduce penalty for longer strings.
        finalScore = 0.5 * (runningScore / Double(strLength) + runningScore / Double(wordLength)) / fuzzies
        if (lWord[lWord.startIndex] == lString[lString.startIndex]) && (finalScore < 0.85) {
            finalScore += 0.15
        }
        
        return finalScore
    }
    
}




