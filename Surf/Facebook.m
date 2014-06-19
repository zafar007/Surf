//
//  Facebook.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Facebook.h"

@implementation Facebook

- (void)getData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Facebook" object:nil];
    NSLog(@"Facebook");
}

@end
