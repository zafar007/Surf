//
//  Tab.h
//  Sapari
//
//  Created by Sapan Bhuta on 5/30/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tab : NSObject
@property NSString *urlString;
@property UIWebView *webView;
@property NSMutableArray *screenshots;
@property NSMutableArray *urls;
@property int currentImageIndex;
@end