//
//  Reddit.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Reddit.h"

@implementation Reddit

- (void)getData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Reddit" object:nil];
    NSLog(@"Reddit");
}

@end
