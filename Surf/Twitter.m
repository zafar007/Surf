//
//  Twitter.m
//  Surf
//
//  Created by Sapan Bhuta on 6/15/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Twitter.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface Twitter ()
@property NSArray *dataSource;
@property NSMutableArray *tweets;
@end

@implementation Twitter

- (void)getTimeLine
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
                 NSURL *requestURL = [NSURL URLWithString: @"https://api.twitter.com/1.1/statuses/home_timeline.json"];
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

@end
