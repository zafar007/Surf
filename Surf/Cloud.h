//
//  Glasses.h
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cloud : NSObject
- (void)getData;
+ (NSDictionary *)layoutFrom:(NSDictionary *)site;
+ (NSString *)selected:(NSDictionary *)site;
+ (CGFloat)width:(NSDictionary *)site;
+ (CGFloat)height:(NSDictionary *)site;
@end
