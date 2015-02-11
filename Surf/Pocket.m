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
    BOOL loggedIntoPocket = (BOOL)[[NSUserDefaults standardUserDefaults] objectForKey:@"pocketLoggedIn"];
    if (loggedIntoPocket) {
        [self getPockets];
    } else {
        [[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error) {
            if (!error) {
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"pocketLoggedIn"];
                [self getPockets];
            }
        }];
    }
}

- (void)getPockets
{
    self.data = [NSMutableArray new];
    [[PocketAPI sharedAPI] callAPIMethod:@"get"
                          withHTTPMethod:PocketAPIHTTPMethodPOST
                               arguments:@{@"sort":@"newest"}
                                 handler:^(PocketAPI *api, NSString *apiMethod, NSDictionary *response, NSError *error) {
        if (!error && response) {
            for (NSDictionary *article in response[@"list"]) {
                NSDictionary *site = @{@"url":response[@"list"][[NSString stringWithFormat:@"%@",article]][@"resolved_url"],
                                       @"title":response[@"list"][[NSString stringWithFormat:@"%@",article]][@"resolved_title"],
                                       @"excerpt":response[@"list"][[NSString stringWithFormat:@"%@",article]][@"excerpt"],
                                       @"item_id":response[@"list"][[NSString stringWithFormat:@"%@",article]][@"item_id"]};

                [self.data addObject:site];
            }

//            [[NSNotificationCenter defaultCenter] postNotificationName:@"Pocket" object:self.data];
        }
        else {
            NSLog(@"error %@", [error localizedDescription]);
            UIAlertView *alert = [[UIAlertView alloc] init];
            alert.title = @"Error Retrieving Data";
            alert.message = @"Please check your internet connection & for an app update (API might be broken)";
            [alert addButtonWithTitle:@"Dismiss"];
            [alert show];
        }
    }];
}

+ (void)archivePocket:(NSString *)item_id {
    [[PocketAPI sharedAPI] callAPIMethod:@"send"
                          withHTTPMethod:PocketAPIHTTPMethodPOST
                               arguments:@{@"actions":@[@{ @"action": @"archive", @"item_id":item_id}]}
                                 handler:^(PocketAPI *api, NSString *apiMethod, NSDictionary *response, NSError *error) {
         NSLog(@"response %@", [response description]);
         NSLog(@"error %@", [error localizedDescription]);
     }];
}

+ (void)deletePocket:(NSString *)item_id {
    [[PocketAPI sharedAPI] callAPIMethod:@"send"
                          withHTTPMethod:PocketAPIHTTPMethodPOST
                               arguments:@{@"actions":@[@{ @"action": @"delete", @"item_id":item_id}]}
                                 handler:^(PocketAPI *api, NSString *apiMethod, NSDictionary *response, NSError *error) {
         NSLog(@"response %@", [response description]);
         NSLog(@"error %@", [error localizedDescription]);
     }];
}

@end
