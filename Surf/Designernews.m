//
//  Designernews.m
//  Surf
//
//  Created by Sapan Bhuta on 6/21/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Designernews.h"

@implementation Designernews

- (void)getData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Designernews" object:nil];
    NSLog(@"Designernews");
}

@end
