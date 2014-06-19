//
//  Feedly.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Feedly.h"

@implementation Feedly

- (void)getData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Feedly" object:nil];
    NSLog(@"Feedly");
}

@end
