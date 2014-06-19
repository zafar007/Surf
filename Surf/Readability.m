//
//  Readability.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Readability.h"

@implementation Readability

- (void)getData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Readability" object:nil];
    NSLog(@"Readability");
}

@end
