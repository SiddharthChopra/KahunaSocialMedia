# KahunaSocialMedia

[![CI Status](http://img.shields.io/travis/siddharthchopra/KahunaSocialMedia.svg?style=flat)](https://travis-ci.org/siddharthchopra/KahunaSocialMedia)
[![Version](https://img.shields.io/cocoapods/v/KahunaSocialMedia.svg?style=flat)](http://cocoapods.org/pods/KahunaSocialMedia)
[![License](https://img.shields.io/cocoapods/l/KahunaSocialMedia.svg?style=flat)](http://cocoapods.org/pods/KahunaSocialMedia)
[![Platform](https://img.shields.io/cocoapods/p/KahunaSocialMedia.svg?style=flat)](http://cocoapods.org/pods/KahunaSocialMedia)

![LogCamp](http://www.kahuna-mobihub.com/templates/ja_puresite/images/logo-trans.png)

KahunaSocialMedia is written in Swift

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

KahunaSocialMedia is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'KahunaSocialMedia', '~> 0.1.15’
```
> _Note:_ You need to update your latest xcode name by Xcode.app and it should by in your Application folder

## Give a reference of sqlite db
```swift
SocialDataHandler.sharedInstance.initSqliteName(kSqliteName)
```

## Set Server URL
```swift
let socialHandler = SocialOperationHandler.sharedInstance
socialHandler.socialDelegate = self
socialHandler.initServerBaseURL(kServerBaseURL)
```
## To fetch from our server or social media server 
```swift
socialHandler.isLoadFromServer = true (i.e. our server and false for social media server)
```

Note:
Add import KahunaSocialMedia into respected file
 
## Retrieve Twitter Feeds from twitter server or from our server

```swift
socialHandler.initAllTwitterKeys(kTwitterURL, tweetAccessToken: kTweetAccessToken, tweetSecretKey: kTweetAccessTokenSecret, tweetConsumerKey: kTweetConsumerKey, tweetConsumerSecret: kTweetConsumerSecret, tweetOwnerSecretName: kTweetOwnerScreenName, tweetSlugName: kTweetSlugName)
socialHandler.getTwitterFeeds() 
  ```
  
   
## Retrieve Facebook Feeds from facebook server or from our server

```swift
socialHandler.initAllFacebookKeys(kFbGraphURL, fbFromName: kFbFromName, fbAppSecret: kFbAppSecret, fbAppID: kFbAppID)
socialHandler.getFacebookFeeds()
  ```
   
## Retrieve Instagram Feeds from instagram server or from our server

```swift
socialHandler.initAllInstagramKeys(instaURL)
socialHandler.getInstagramFeeds()
  ```
 
## Retrieve Youtube Feeds from youtube server or from our server
Retrieve based on user channel
```swift
socialHandler.initAllYoutubeKeys(kYoutubeUrl, youTubeAPIKey: kYoutubeAPIKey, youTubeUser: kYouTubeUser, videosCountForSubscriptionChannel: kVideosCountForSubscriptionChannel, countForSubscribedChannel: kCountForSubscribedChannel, userChannelId: kUserChannelId, userChannelOnly:true , isLoadFromSubscriptions: "false")
socialHandler.getYouTubeFeeds()
  ```
Retrieve based on user subscriptions channel
```swift
socialHandler.initAllYoutubeKeys(kYoutubeUrl, youTubeAPIKey: kYoutubeAPIKey, youTubeUser: kYouTubeUser, videosCountForSubscriptionChannel: kVideosCountForSubscriptionChannel, countForSubscribedChannel: kCountForSubscribedChannel, userChannelId: "", userChannelOnly:false , isLoadFromSubscriptions: isLoadFromSubscriptions)
socialHandler.getYouTubeFeeds()
  ```

## Author

siddharthchopra, siddharth.chopra@kahunasystems.com

## License

KahunaSocialMedia is available under the MIT license. See the LICENSE file for more info.
