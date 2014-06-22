//
//  History.m
//  Surf
//
//  Created by Sapan Bhuta on 6/21/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "History.h"

@implementation History

- (void)getData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"History" object:nil];
    NSLog(@"History");
}

@end
