//
//  Tab.m
//  Surf
//
//  Created by Sapan Bhuta on 5/30/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Tab.h"

@implementation Tab

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.cornerRadius = 4.0;
        self.layer.masksToBounds = YES;
        self.scalesPageToFit = YES;
        self.backgroundColor = [UIColor clearColor];
//        self.scrollView.bounces = NO;
    }
    return self;
}

@end
