//
//  FacebookPublicFeedsHandler.swift
//  MyCity311
//
//  Created by Piyush on 6/9/16.
//  Copyright © 2016 Kahuna Systems. All rights reserved.
//

import UIKit

@objc protocol FacebookFeedDelegate: class {
    @objc optional func facebookFeedFetchSuccess(_ feedArray: NSArray?)
    @objc optional func facebookFeedFetchError(_ errorType: NSError)
}

class FacebookPublicFeedsHandler: NSObject {

    static let sharedInstance = FacebookPublicFeedsHandler()
    weak var fBFeedFetchDelegate: FacebookFeedDelegate!
    let userDefault = UserDefaults.standard

    override init() {
    }

    deinit {
        print("** FacebookPublicFeedsHandler deinit called **")
    }

    func getFacebookFeedListFromURL(stringURL: String) {
        autoreleasepool() {
            let basePath = SocialOperationHandler.sharedInstance.serverBaseURL
            let paramString = basePath + stringURL
            let loadURL = NSURL(string: paramString)
            let request = NSURLRequest(url: loadURL! as URL)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                if error != nil && self.fBFeedFetchDelegate != nil {
                    self.fBFeedFetchDelegate.facebookFeedFetchError!(error! as NSError)
                } else if data != nil {
                    DispatchQueue.main.async {
                        let parcer = FacebookFeedsJsonParser()
                        let parsedArray = parcer.parseData(feedsData: data! as NSData)
                        if parsedArray != nil && (parsedArray?.count)! > 0 {
                            SocialOperationHandler.sharedInstance.socialDBStore.saveAllFetchedFacebookFeedsToDB(fbFeedArray: parsedArray as! NSMutableArray)
                        }
                        if self.fBFeedFetchDelegate != nil {
                            self.fBFeedFetchDelegate.facebookFeedFetchSuccess!(parsedArray)
                        }
                    }
                }
            })
            task.resume()
        }
    }

    func getPublicFeedsFromUserName(fbUrl: String) {
        autoreleasepool() {
            var paramFBUrl = fbUrl as NSString
            paramFBUrl = paramFBUrl.replacingOccurrences(of: " ", with: "+") as NSString
            paramFBUrl = paramFBUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)! as NSString
            let appID = SocialOperationHandler.sharedInstance.fbAppID
            let appSecret = SocialOperationHandler.sharedInstance.fbAppSecret
            var accessToken = ""
            let accessDataURLString = String(format: Constants.kFacebookURL, appID, appSecret)
            let loadURL = NSURL(string: accessDataURLString)
            let request = NSURLRequest(url: loadURL! as URL)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                if error != nil && self.fBFeedFetchDelegate != nil {
                    self.fBFeedFetchDelegate?.facebookFeedFetchError!(error! as NSError)
                } else if data != nil {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        if let jsonDictionary = json as? NSDictionary, let tempToken = jsonDictionary["access_token"] as? String {
                            accessToken = tempToken
                        } else {
                            if let jsonString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                                var seperateArray = jsonString.components(separatedBy: "=")
                                if seperateArray.count > 1 {
                                    accessToken = seperateArray[1]
                                }
                            }
                        }
                    } catch let error as NSError {
                        print(error.debugDescription)
                    }
                    self.loadFacebookFeedsWithAccessToken(accessToken: accessToken, facebookURL: paramFBUrl as String)
                }
            })
            task.resume()
        }
    }

    func loadFacebookFeedsWithAccessToken(accessToken: String, facebookURL: String) {
        let accessDataURLString = String(format: facebookURL, accessToken) as NSString
        var paramFBUrl = accessDataURLString.replacingOccurrences(of: " ", with: "+") as NSString
        paramFBUrl = paramFBUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)! as NSString
        let loadURL = NSURL(string: paramFBUrl as String)
        let request = NSURLRequest(url: loadURL! as URL)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            if error != nil && self.fBFeedFetchDelegate != nil {
                self.fBFeedFetchDelegate?.facebookFeedFetchError!(error! as NSError)
            } else if data != nil {
                DispatchQueue.main.async {
                    let parcer = FacebookFeedsJsonParser()
                    let parsedArray = parcer.parseData(feedsData: data! as NSData)
                    if parsedArray != nil && (parsedArray?.count)! > 0 {
                        SocialOperationHandler.sharedInstance.socialDBStore.saveAllFetchedFacebookFeedsToDB(fbFeedArray: parsedArray as! NSMutableArray)
                    }
                    if self.fBFeedFetchDelegate != nil {
                        self.fBFeedFetchDelegate?.facebookFeedFetchSuccess!(parsedArray)
                    }
                }
            }
        })
        task.resume()
    }

}
