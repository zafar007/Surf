//
//  AppDelegate.m
//  Surf
//
//  Created by Sapan Bhuta on 5/30/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSArray *services = @[
                         @"bookmarks",
                         @"cloud",
                         @"history",
                         @"twitter",
                         @"global",
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
    [[NSUserDefaults standardUserDefaults] setObject:services forKey:@"buttonsFull"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.rootViewController = [[RootViewController alloc] init];
    [self.window setRootViewController:self.rootViewController];

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    [self.rootViewController saveTabs];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {}

- (void)applicationWillTerminate:(UIApplication *)application {}

@end