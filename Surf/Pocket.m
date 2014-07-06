//
//  Pocket.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define kAPI @"https://getpocket.com/v3/get"

#import "Pocket.h"
#import "PocketAPI.h"

@interface Pocket ()
@property NSMutableArray *data;
@end

@implementation Pocket

- (void)getData
{
    NSLog(@"Pocket, user: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"pocketLoggedIn"]);


    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"pocketLoggedIn"])
    {
        [[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error)
        {
            if (!error)
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"pocketLoggedIn"];
                [self getPockets];
            }
        }];
    }
    else
    {
        [self getPockets];
    }
}

- (void)getPockets
{
    self.data = [NSMutableArray new];

    [[PocketAPI sharedAPI] callAPIMethod:@"get"
                          withHTTPMethod:PocketAPIHTTPMethodPOST
                               arguments:@{}
                                 handler:^(PocketAPI *api, NSString *apiMethod, NSDictionary *response, NSError *error)
    {
        if (!error && response)
        {
//            NSLog(@"response %@", [response description]);

            for (NSDictionary *article in response[@"list"])
            {
                NSDictionary *site = @{@"url":response[@"list"][[NSString stringWithFormat:@"%@",article]][@"resolved_url"],
                                       @"title":response[@"list"][[NSString stringWithFormat:@"%@",article]][@"resolved_title"],
                                       @"excerpt":response[@"list"][[NSString stringWithFormat:@"%@",article]][@"excerpt"],
                                       @"item_id":response[@"list"][[NSString stringWithFormat:@"%@",article]][@"item_id"]};

                [self.data addObject:site];
            }

//            NSLog(@"data %@",self.data);

            [[NSNotificationCenter defaultCenter] postNotificationName:@"Pocket" object:self.data];
        }
        else
        {
            NSLog(@"error %@", [error localizedDescription]);

            UIAlertView *alert = [[UIAlertView alloc] init];
            alert.title = @"Error Retrieving Data";
            alert.message = @"Please check your internet connection & for an app update (API might be broken)";
            [alert addButtonWithTitle:@"Dismiss"];
            [alert show];
        }
    }];
}

+ (NSDictionary *)layoutFrom:(NSDictionary *)site
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self width:site], [self height:site])];
    contentView.backgroundColor = [UIColor whiteColor];

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 0, 300, contentView.frame.size.height)];
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.origin.x+20,
                                                                  contentView.frame.size.height-.5,
                                                                  contentView.frame.size.width-20,
                                                                  .5)];

    NSURL *url = [NSURL URLWithString:site[@"url"]];
    NSString *host = url.host;
    if ([host hasPrefix:@"www."])
    {
        host = [host substringFromIndex:[@"www." length]];
    }

    textView.text = [NSString stringWithFormat:@"%@\n%@",site[@"title"],host];
    textView.font = [UIFont systemFontOfSize:13];
    textView.editable = NO;
    textView.selectable = NO;
    textView.userInteractionEnabled = NO;

    borderView.backgroundColor = [UIColor lightGrayColor];

    [contentView addSubview:textView];
    [contentView addSubview:borderView];

//    UIColor *pocketColor = [UIColor colorWithRed:0.996 green:0.118 blue:0.192 alpha:1]; /*#fe1e31*/

    return @{@"simple":@NO,
             @"text":site[@"title"],
             @"subtext":host,
             @"contentView":contentView};
}

+ (NSString *)selected:(NSDictionary *)site
{
    return site[@"url"];
}

+ (CGFloat)width:(NSDictionary *)site
{
    return 320;
}

+ (CGFloat)height:(NSDictionary *)site
{
    return 68;
}

- (void)deletePocket
{
    NSError *error;
    NSArray *actions = @[@{ @"action": @"delete", @"item_id": @"456853615" }];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: actions
                                                       options: kNilOptions
                                                         error: &error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding: NSUTF8StringEncoding];

    NSDictionary* argumentDictionary = @{@"actions":jsonString};

    [[PocketAPI sharedAPI] callAPIMethod:@"send"
                          withHTTPMethod:PocketAPIHTTPMethodPOST
                               arguments:argumentDictionary
                                 handler:^(PocketAPI *api, NSString *apiMethod, NSDictionary *response, NSError *error)
    {
        NSLog(@"response %@", [response description]);
        NSLog(@"error %@", [error localizedDescription]);
    }];
}

@end
