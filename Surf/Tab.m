//
//  Tab.m
//  Surf
//
//  Created by Sapan Bhuta on 5/30/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Tab.h"

@implementation Tab

- (id)init
{
    self = [super init];
    self.webView = [UIWebView new];
    self.screenshot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back.png"]];
    self.started = NO;

    return self;
}

@end
