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
    [[PocketAPI sharedAPI] setConsumerKey:@"29159-d90fcf8425ecacb6bcdf588e"];

    NSArray *services = @[
                         @"bookmarks",
                         @"history",
                         @"twitter",
                         @"global",
                         @"gmail",
                         @"hackernews",
                         @"producthunt",
                         @"dribbble",
                         @"designernews",
                         @"facebook",
                         @"reddit",
                         @"feedly",
                         @"pocket",
                         @"instapaper",
                         @"readability"
                         ];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"buttonsFull"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:services forKey:@"buttonsFull"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.rootViewController = [[RootViewController alloc] init];
    [self.window setRootViewController:self.rootViewController];

    self.window.backgroundColor = [UIColor whiteColor];
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

- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.rootViewController saveTabs];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {}

- (void)applicationWillTerminate:(UIApplication *)application {}

@end