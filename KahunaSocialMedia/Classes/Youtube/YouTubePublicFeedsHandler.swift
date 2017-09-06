//
//  YouTubePublicFeedsHandler.swift
//  MyCity311
//
//  Created by Piyush on 6/14/16.
//  Copyright © 2016 Kahuna Systems. All rights reserved.
//

import UIKit

@objc protocol YouTubeFeedDelegate: class {
    @objc optional func youTubeFeedFetchSuccess(_ feedArray: NSArray?)
    @objc optional func youTubeFeedFetchError(_ error: NSError?)
}

class YouTubePublicFeedsHandler: NSObject {

    weak var youTubeDelegate: YouTubeFeedDelegate!
    static let sharedInstance = YouTubePublicFeedsHandler()
    let userDefault = NSUserDefaults.standardUserDefaults()

    override init() {
    }

    deinit {
        print("** YouTubePublicFeedsHandler deinit called **")
    }

    func getYouTubeFeedListFromURL(stringURL: String) {
        let basePath = SocialOperationHandler.sharedInstance.serverBaseURL
        let paramString = basePath + stringURL
        let loadURL = NSURL(string: paramString)
        let request = NSURLRequest(URL: loadURL!)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if error != nil {
                if self.youTubeDelegate != nil {
                    self.youTubeDelegate!.youTubeFeedFetchError!(error! as NSError?)
                }
            } else if data != nil {
                let parserArray = NSMutableArray()
                let parcer = YouTubeJSONParser()
                let parsedArray = parcer.parseYoutubeData(data! as NSData, parserArray: parserArray) as NSMutableArray
                dispatch_async(dispatch_get_main_queue()) {
                    if parsedArray.count > 0 {
                        SocialDataHandler.sharedInstance.saveAllFetchedYoutubeFeedsToDB(parsedArray)
                    }
                    if self.youTubeDelegate != nil {
                        self.youTubeDelegate!.youTubeFeedFetchSuccess!(parsedArray)
                    }
                }
            }
        })
        task.resume()
    }

    func getYouTubeFeedsFromURL(stringURL: String?) {
        if stringURL != nil {
            var paramString = ""
            let range = stringURL!.rangeOfString("?")
            if range?.endIndex > range?.startIndex {
                paramString = String(format: "%@/alt=json", stringURL!)
            } else {
                paramString = String(format: "%@/alt&json", stringURL!)
            }
            paramString = paramString.stringByReplacingOccurrencesOfString(" ", withString: "%20")
            let loadURL = NSURL(string: paramString)
            let request = NSURLRequest(URL: loadURL!)
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if error != nil {
                    if self.youTubeDelegate != nil {
                        self.youTubeDelegate!.youTubeFeedFetchError!(error! as NSError?)
                    }
                } else if data != nil {
                    let parserArray = NSMutableArray()
                    let parcer = YouTubeJSONParser()
                    let parsedArray = parcer.parseYoutubeData(data! as NSData, parserArray: parserArray) as NSMutableArray
                    dispatch_async(dispatch_get_main_queue()) {
                        if parsedArray.count > 0 {
                            SocialDataHandler.sharedInstance.saveAllFetchedYoutubeFeedsToDB(parsedArray)
                        }
                        if self.youTubeDelegate != nil {
                            self.youTubeDelegate!.youTubeFeedFetchSuccess!(parsedArray)
                        }
                    }
                }
            })
            task.resume()
        }
    }

    func getUsersSubscriptionsData() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            self.getUploadsForEachSubscription()
        }
    }

    func getUploadsForEachSubscription() {
        let subsciptionArray = self.getCurrentUsersSubscriptions()
        var numberOfVideos = "5"
        if SocialOperationHandler.sharedInstance.videosCountForSubscriptionChannel.characters.count > 0 {
            numberOfVideos = SocialOperationHandler.sharedInstance.videosCountForSubscriptionChannel
        }
        var parserArray = NSMutableArray()
        if subsciptionArray != nil {
            for i in 0 ..< subsciptionArray!.count {
                let subsciptionChannelURL = String(format: "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=%@&maxResults=%@&order=date&type=video&fields=items&key=%@", (subsciptionArray![i] as! String), numberOfVideos, SocialOperationHandler.sharedInstance.youTubeAPIKey)
                let urlToLoad = NSURL(string: subsciptionChannelURL)
                var response: NSURLResponse?
                do {
                    let data = try NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: urlToLoad!), returningResponse: &response)
                    let parcer = YouTubeJSONParser()
                    let parsedArray = parcer.parseYoutubeData(data as NSData, parserArray: parserArray)
                    parserArray = NSMutableArray(array: parsedArray)
                } catch (let e) {
                    print(e)
                    if self.youTubeDelegate != nil {
                        self.youTubeDelegate!.youTubeFeedFetchError!(nil)
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
            if parserArray.count > 0 {
                SocialDataHandler.sharedInstance.saveAllFetchedYoutubeFeedsToDB(parserArray)
            }
            if self.youTubeDelegate != nil {
                self.youTubeDelegate!.youTubeFeedFetchSuccess!(parserArray)
            }
        }
    }

    func getCurrentUsersSubscriptions() -> NSArray? {
        if SocialOperationHandler.sharedInstance.userChannelOnly {
            if SocialOperationHandler.sharedInstance.userChannelId.characters.count == 0 {
                if let channelID = self.getUserChannelID() {
                    return [channelID]
                }
            }
            return [SocialOperationHandler.sharedInstance.userChannelId]
        } else {
            //Static content
            let channelID = self.getUserChannelID()
            if channelID != nil {
                var numberOfChannels = "50"
                if SocialOperationHandler.sharedInstance.countForSubscribedChannel.characters.count > 0 {
                    numberOfChannels = SocialOperationHandler.sharedInstance.countForSubscribedChannel
                }
                var urlString = String(format: "https://www.googleapis.com/youtube/v3/subscriptions?part=snippet&channelId=%@&maxResults=%@&order=relevance&fields=items/snippet&key=%@", channelID!, numberOfChannels, SocialOperationHandler.sharedInstance.youTubeAPIKey) as NSString
                urlString = urlString.stringByReplacingOccurrencesOfString(" ", withString: "%20")
                let urlToLoad = NSURL(string: urlString as String)
                var response: NSURLResponse?
                do {
                    let data = try NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: urlToLoad!), returningResponse: &response)
                    let subscriptionArray = self.arrayOfParsedSubscriptionsData(data as NSData)
                    return subscriptionArray
                }
                catch (let e) {
                    print(e)
                    if self.youTubeDelegate != nil {
                        self.youTubeDelegate?.youTubeFeedFetchError!(nil)
                    }
                }
            }
        }
        return nil
    }

    func arrayOfParsedSubscriptionsData(subscriptionsData: NSData) -> NSMutableArray {
        let subscriptionsArray = NSMutableArray()
        let stringData = String(data: subscriptionsData, encoding: NSUTF8StringEncoding)
        let parseDict = self.readFileFromPathAndSerializeIt(stringData!, errorMessage: "arrayOfParsedSubscriptionsData")
        if let myArray = parseDict!["items"] {
            let items: NSArray = (myArray as? NSArray)!
            for i in 0 ..< items.count {
                if let dict = items[i] as? NSDictionary, let arrayFeed = dict["snippet"] as? NSDictionary, let tempDic = arrayFeed["resourceId"] as? NSDictionary {
                    if tempDic.count > 0 {
                        if let feedUrl = tempDic["channelId"] {
                            subscriptionsArray.addObject(feedUrl)
                        }
                    }
                }
            }
        }
        return subscriptionsArray
    }

    //MARK: GET CHANNEL ID FOR YOUTUBE
    func getUserChannelID() -> String? {
        print("Fetching Current Users Channel ID")
        let userName = SocialOperationHandler.sharedInstance.youTubeUser
        var urlString = String(format: "https://www.googleapis.com/youtube/v3/channels?part=id&forUsername=  %@&fields=items(id,statistics,status,topicDetails)&key=%@", userName, SocialOperationHandler.sharedInstance.youTubeAPIKey) as NSString
        urlString = urlString.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        let url = NSURL(string: urlString as String)
        var response: NSURLResponse?
        do {
            let data = try NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: url!), returningResponse: &response)
            let stringData = String(data: data, encoding: NSUTF8StringEncoding)
            let parseDict = self.readFileFromPathAndSerializeIt(stringData!, errorMessage: "Fetching Current Users Channel ID")
            if parseDict != nil {
                if let myArray = parseDict!["items"] {
                    let items: NSArray = (myArray as? NSArray)!
                    if items.count > 0 {
                        if let dict = items[0] as? NSDictionary, let channelID = dict["id"] {
                            return channelID as? String
                        }
                    }
                }
            }
        } catch (let e) {
            print(e)
            if self.youTubeDelegate != nil {
                self.youTubeDelegate?.youTubeFeedFetchError!(nil)
            }
        }
        return nil
    }


    //MARK:- Read file from path and Serialize it
    func readFileFromPathAndSerializeIt(stringData: String, errorMessage: String) -> AnyObject? {
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding)
        do {
            let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            return jsonArray
        } catch let error as NSError {
            print("Error in \(errorMessage) fetch JSON File\(error.description)")
        }
        return nil
    }

}
