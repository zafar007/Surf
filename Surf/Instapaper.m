//
//  Instapaper.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Instapaper.h"

@implementation Instapaper

- (void)getData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Instapaper" object:nil];
    NSLog(@"Instapaper");
}

@end
