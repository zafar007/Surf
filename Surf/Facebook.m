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
//@property NSArray *posts;
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
//                          self.posts = self.dataSource[@"data"];

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
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self width:post], [self height:post])];
    contentView.backgroundColor = [UIColor whiteColor];

    NSString *textLabel;
    NSString *detailTextLabel;
    NSString *imgUrlString;

    if (post[@"story"])
    {
        textLabel = post[@"story"];
    }
    else if (post[@"message"])
    {
        textLabel = post[@"message"];
    }

    if (post[@"from"][@"name"])
    {
        detailTextLabel = post[@"from"][@"name"];
    }

    if (post[@"picture"])
    {
        imgUrlString = post[@"picture"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,contentView.frame.size.width,contentView.frame.size.height)];
        [imageView setImageWithURL:[NSURL URLWithString:imgUrlString] placeholderImage:[UIImage imageNamed:@"bluewave"]];
        [contentView addSubview:imageView];
    }

//    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10+48+10, 0, 320-68-5, contentView.frame.size.height)];
//    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.origin.x+20,
//                                                                  contentView.frame.size.height-.5,
//                                                                  contentView.frame.size.width-20,
//                                                                  .5)];

//    textView.text = [NSString stringWithFormat:@"%@\n\n%@",textLabel,detailTextLabel];
//    textView.font = [UIFont systemFontOfSize:13];
//    textView.editable = NO;
//    textView.selectable = NO;
//    textView.userInteractionEnabled = NO;


    return @{@"contentView":contentView};
}

+ (NSString *)selected:(NSDictionary *)post
{
    return post[@"action"][0][@"link"];
}

+ (CGFloat)width:(NSDictionary *)post
{
    return 320/4;
}

+ (CGFloat)height:(NSDictionary *)post
{
    return 320/4;
}
@end
