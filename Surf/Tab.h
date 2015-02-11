//
//  Tab.h
//  Surf
//
//  Created by Sapan Bhuta on 5/30/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface Tab : WKWebView
@property NSString *urlString;
@property UIView *screenshot;
@end