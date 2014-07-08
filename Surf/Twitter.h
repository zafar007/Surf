//
//  Twitter.h
//  Surf
//
//  Created by Sapan Bhuta on 6/15/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Twitter : NSObject
- (void)getData;
+ (NSDictionary *)layoutFrom:(NSDictionary *)tweet;
+ (NSString *)selected:(NSDictionary *)tweet;
+ (CGFloat)width:(NSDictionary *)tweet;
+ (CGFloat)height:(NSDictionary *)tweet;
+ (void)retweet:(NSDictionary *)tweet;
+ (void)retweetAdvanced:(NSDictionary *)tweet;
@end
