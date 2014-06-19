//
//  Bookmarks.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Bookmarks.h"

@implementation Bookmarks

- (void)getData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Bookmarks" object:nil];
    NSLog(@"Bookmarks");
}

@end
