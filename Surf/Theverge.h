//
//  Theverge.h
//  Surf
//
//  Created by Sapan Bhuta on 7/19/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Theverge : NSObject
- (void)getData;
+ (NSDictionary *)layoutFrom:(NSDictionary *)post;
+ (NSString *)selected:(NSDictionary *)post;
+ (CGFloat)width:(NSDictionary *)post;
+ (CGFloat)height:(NSDictionary *)post;
@end