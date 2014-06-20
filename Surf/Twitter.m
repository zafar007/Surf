//
//  Twitter.m
//  Surf
//
//  Created by Sapan Bhuta on 6/15/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define kAPI @"https://api.twitter.com/1.1/statuses/home_timeline.json"

#import "Twitter.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface Twitter ()
@property NSArray *dataSource;
@property NSMutableArray *tweets;
@end

@implementation Twitter

- (void)getData
{
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
                 NSDictionary *parameters = @{@"count" : @"200"};
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
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"Twitter" object:self.tweets];
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
     }
     ];
}

- (void)filterTweetsForLinkedPosts
{
    self.tweets = [NSMutableArray new];

    for (NSDictionary *tweet in self.dataSource)
    {
        NSArray *urls = tweet[@"entities"][@"urls"];

        if (urls.count)
        {
            [self.tweets addObject:tweet];
        }
    }
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

+ (NSString *)selected:(NSDictionary *)tweet
{
    return tweet[@"entities"][@"urls"][0][@"expanded_url"];
}

+ (CGFloat)height:(NSDictionary *)tweet
{
    return 120;
}

@end
