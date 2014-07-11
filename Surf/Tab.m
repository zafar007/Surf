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
        [self.layer setCornerRadius:4.0];
        [self.layer setBorderColor:[UIColor blackColor].CGColor];
        [self.layer setBorderWidth:0.5];
        self.layer.masksToBounds = YES;

//        [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com"]]];
//        self.scalesPageToFit = YES;
//        self.userInteractionEnabled = NO;
    }
    return self;
}

@end
