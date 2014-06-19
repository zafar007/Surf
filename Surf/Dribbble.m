//
//  Dribbble.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Dribbble.h"

@implementation Dribbble

- (void)getData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Dribbble" object:nil];
    NSLog(@"Dribbble");
}

@end
