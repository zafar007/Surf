//
//  Glasses.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Cloud.h"

@implementation Cloud

- (void)getData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Cloud" object:nil];
    NSLog(@"Cloud");
}

@end
