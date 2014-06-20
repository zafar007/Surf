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
#import "SDWebImage/UIImageView+WebCache.h"

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

                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"Global" object:self.tweets];
                              });

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
        if (!tweet[@"retweeted_status"])
        {
            [self.tweets addObject:tweet];
        }
    }
}

- (void)saveURL:(NSNotification *)notification
{
    self.url = notification.object;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"url" object:nil];
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

+ (NSDictionary *)layoutFrom:(NSDictionary *)tweet
{
    NSDictionary *originalTweet = tweet;
    NSDictionary *retweet = tweet[@"retweeted_status"];

    NSString *textLabel;
    NSString *detailTextLabel;
    NSString *imgUrlString;

    if (retweet)
    {
        tweet = retweet;
        detailTextLabel = [NSString stringWithFormat:@"%@\nRetweeted by: %@",tweet[@"user"][@"name"], originalTweet[@"user"][@"name"]];
    }
    else
    {
        detailTextLabel = tweet[@"user"][@"name"];
    }

    textLabel = [self modifyTweetText:tweet];
    imgUrlString = tweet[@"user"][@"profile_image_url"];

    //data now convert to view

    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self width:tweet], [self height:tweet])];
    contentView.backgroundColor = [UIColor whiteColor];

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10+48+10, 0, 320-68-5, contentView.frame.size.height)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,48,48)];
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.origin.x+20,
                                                                  contentView.frame.size.height-.5,
                                                                  contentView.frame.size.width-20,
                                                                  .5)];

    textView.text = [NSString stringWithFormat:@"%@\n\n%@",textLabel,detailTextLabel];
    textView.font = [UIFont systemFontOfSize:13];
    textView.editable = NO;
    textView.selectable = NO;
    textView.userInteractionEnabled = NO;

    [imageView setImageWithURL:[NSURL URLWithString:imgUrlString] placeholderImage:[UIImage imageNamed:@"bluewave"]];
    imageView.center = CGPointMake(10+24, CGRectGetMidY(contentView.frame));
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 48/2;

    borderView.backgroundColor = [UIColor lightGrayColor];

    [contentView addSubview:textView];
    [contentView addSubview:imageView];
    [contentView addSubview:borderView];

    return @{@"contentView":contentView};
}

+ (CGFloat)width:(NSDictionary *)tweet
{
    return 320;
}

+ (CGFloat)height:(NSDictionary *)tweet
{
    return 120;
}

@end
