//
//  Pinterest.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Pinterest.h"

@implementation Pinterest

- (void)getData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Pinterest" object:nil];
    NSLog(@"Pinterest");
}

@end
