//
//  Global.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define kAPI @"https://api.twitter.com/1.1/search/tweets.json"

#import "Global.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface Global ()
@property NSDictionary *dataSource;
@property NSString *url;
@property NSMutableArray *tweets;
@end

@implementation Global

- (void)getData
{
    NSLog(@"Global");

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveURL:) name:@"url" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentURL" object:nil];

    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];

             if ([arrayOfAccounts count] > 0)
             {
                 ACAccount *twitterAccount = arrayOfAccounts.lastObject;
                 NSURL *requestURL = [NSURL URLWithString: kAPI];

                 NSData *asciiData = [self.url dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                 NSString *asciiString = [[NSString alloc] initWithData:asciiData encoding:NSASCIIStringEncoding];
                 NSDictionary *parameters = @{@"q" : asciiString, @"count":@"100", @"lang":@"en"};

                 SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                             requestMethod:SLRequestMethodGET
                                                                       URL:requestURL
                                                                parameters:parameters];
                 postRequest.account = twitterAccount;
                 [postRequest performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      if (!error)
                      {
                          self.dataSource = [NSJSONSerialization JSONObjectWithData:responseData
                                                                            options:NSJSONReadingMutableLeaves
                                                                              error:&error];
                          if (!error)
                          {
                              [self filterTweetsForLinkedPosts];
                              if (self.tweets.count != 0)
                              {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"Global" object:self.tweets];
                                  });
                              }
                          }
                          else
                          {
                              UIAlertView *alert = [[UIAlertView alloc] init];
                              alert.title = @"Error Understanding Twitter Data";
                              alert.message = @"Please retry later and check for an app update";
                              [alert addButtonWithTitle:@"Dismiss"];
                              [alert show];
                          }
                      }
                      else
                      {
                          UIAlertView *alert = [[UIAlertView alloc] init];
                          alert.title = @"Error Connecting to Twitter";
                          alert.message = @"Please check your internet connection";
                          [alert addButtonWithTitle:@"Dismiss"];
                          [alert show];
                      }
                  }];
             }
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] init];
             alert.title = @"Error Authenticating to Twitter";
             alert.message = @"Please login to Twitter in the settings app";
             [alert addButtonWithTitle:@"Dismiss"];
             [alert show];
         }
     }];
}

- (void)filterTweetsForLinkedPosts
{
    self.tweets = [NSMutableArray new];

    for (NSDictionary *tweet in self.dataSource[@"statuses"])
    {
            [self.tweets addObject:tweet];
    }
}

- (void)saveURL:(NSNotification *)notification
{
    self.url = notification.object;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"url" object:nil];
}

+ (NSDictionary *)layoutFrom:(NSDictionary *)tweet
{
    NSDictionary *originalTweet = tweet;
    NSDictionary *retweet = tweet[@"retweeted_status"];
    NSString *textLabel;
    NSString *detailTextLabel;
    NSNumber *numberOfLines = @1;
    NSString *imgUrlString;

    if (retweet)
    {
        tweet = retweet;
        detailTextLabel = [NSString stringWithFormat:@"%@\nRetweeted by: %@",tweet[@"user"][@"name"], originalTweet[@"user"][@"name"]];
        numberOfLines = @2;
    }
    else
    {
        detailTextLabel = tweet[@"user"][@"name"];
    }

    textLabel = [self modifyTweetText:tweet];
    imgUrlString = tweet[@"user"][@"profile_image_url"];

    return @{@"textLabel":textLabel,
             @"detailTextLabel":detailTextLabel,
             @"numberOfLines":numberOfLines,
             @"imgUrlString":imgUrlString};
}

+ (NSString *)modifyTweetText:(NSDictionary *)tweet
{
    NSString *tweetText = tweet[@"text"];
    NSURL *url = [NSURL URLWithString:tweet[@"entities"][@"urls"][0][@"expanded_url"]];
    NSArray *indices = tweet[@"entities"][@"urls"][0][@"indices"];
    int index0 = [indices[0] intValue];
    int index1 = [indices[1] intValue];
    NSString *host = url.host;
    NSString *newTweetText = [tweetText stringByReplacingCharactersInRange:NSMakeRange(index0, index1-index0) withString:host];

    return [self cleanup:newTweetText];
}

+ (NSString *)cleanup:(NSString *)tweetText
{
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&apos;" withString:@"\'"];
    return tweetText;
}

@end
