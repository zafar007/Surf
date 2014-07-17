//
//  RSS.h
//  Surf
//
//  Created by Sapan Bhuta on 7/17/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSS : NSObject
- (void)getData:(NSString *)apiString;
+ (NSDictionary *)layoutFrom:(NSDictionary *)post;
+ (NSString *)selected:(NSDictionary *)post;
+ (CGFloat)width:(NSDictionary *)post;
+ (CGFloat)height:(NSDictionary *)post;
@end
