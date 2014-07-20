//
//  AppDelegate.m
//  Surf
//
//  Created by Sapan Bhuta on 5/30/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "AppDelegate.h"
#import "PocketAPI.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self tempSettings];

    [[PocketAPI sharedAPI] setConsumerKey:@"29159-d90fcf8425ecacb6bcdf588e"];

    NSArray *services = @[
                         @"twitter",
                         @"hackernews",
                         @"designernews",
                         @"dribbble",
                         @"techcrunch",
                         @"theverge",
                         @"pocket",
                         @"global",
                         @"history",
//                         @"facebook",
//                         @"reddit",
//                         @"gmail",
//                         @"feedly",
//                         @"instapaper",
//                         @"readability",
//                         @"producthunt",
//                         @"rss"
//                         @"bookmarks",
                         ];

    [[NSUserDefaults standardUserDefaults] setObject:services forKey:@"buttonsFull"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    RootViewController *rootViewController = [[RootViewController alloc] init];
    [self.window setRootViewController:rootViewController];

    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[PocketAPI sharedAPI] handleOpenURL:url])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)tempSettings
{
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reloadOldTabsOnStart"];
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"MLPAutoComplete"];
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"pocketLoggedIn"];
}

@end