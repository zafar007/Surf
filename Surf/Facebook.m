//
//  Facebook.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Facebook.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "SDWebImage/UIImageView+WebCache.h"

@interface Facebook ()
@property NSDictionary *dataSource;
@property NSMutableArray *posts;
@end

@implementation Facebook

- (void)getData
{
    NSLog(@"Facebook");

    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountTypeFacebook = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{ACFacebookAppIdKey: @"324779421012185",
                              ACFacebookPermissionsKey: @[@"email",@"read_stream"],
                              ACFacebookAudienceKey: ACFacebookAudienceFriends};

    [accountStore requestAccessToAccountsWithType:accountTypeFacebook options:options completion:^(BOOL granted, NSError *error)
     {
         if(granted)
         {
             NSArray *accounts = [accountStore accountsWithAccountType:accountTypeFacebook];
             ACAccount *facebookAccount = accounts.lastObject;
             NSDictionary *parameters = @{@"access_token":facebookAccount.credential.oauthToken};

             NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/v2.0/me/home"];
             SLRequest *feedRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                         requestMethod:SLRequestMethodGET
                                                                   URL:feedURL
                                                            parameters:parameters];

             [feedRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
              {
                  if (!error)
                  {
                      self.dataSource = [NSJSONSerialization JSONObjectWithData:responseData
                                                                        options:NSJSONReadingMutableLeaves
                                                                          error:&error];
                      if (!error)
                      {
                          [self filterDataForLinkedPosts];

                          if (self.posts.count != 0)
                          {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"Facebook" object:self.posts];
                              });
                          }
                      }
                      else
                      {
                          NSLog(@"Error understanding api data: %@", error);
                      }
                  }
                  else
                  {
                      NSLog(@"Request failed, %@", [urlResponse description]);
                  }
              }];
         }
         else
         {
             NSLog(@"Access Denied");
             NSLog(@"[%@]",[error localizedDescription]);
         }
     }];
}

- (void)filterDataForLinkedPosts
{
    self.posts = [NSMutableArray new];

    for (NSDictionary *post in self.dataSource[@"data"])
    {
        if ([post[@"status_type"] isEqualToString:@"shared_story"])
        {
            [self.posts addObject:post];
        }
    }
}

+ (NSDictionary *)layoutFrom:(NSDictionary *)post
{
    NSString *textLabel = @"";
    NSString *detailTextLabel = @"";
    NSString *image = @"";

    if (post[@"message"])
    {
        textLabel = post[@"message"];
    }
    else if (post[@"name"])
    {
        textLabel = post[@"name"];
    }
    detailTextLabel = post[@"from"][@"name"];
    image = post[@"picture"];

    return @{
             @"simple":@YES,
             @"text":textLabel,
             @"subtext":detailTextLabel,
             @"image":image,
             @"Cell1Exist":@YES,
             @"Cell1Image":@"pocket-cell",
             @"Cell1Color":[UIColor colorWithRed:0.941 green:0.243 blue:0.337 alpha:1],
             @"Cell1Mode":@2
             };
}

+ (NSString *)selected:(NSDictionary *)post
{
    return post[@"actions"][0][@"link"];
}

+ (CGFloat)width:(NSDictionary *)post
{
    return 320;
}

+ (CGFloat)height:(NSDictionary *)post
{
    return 100;
}
@end
