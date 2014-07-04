//
//  History.h
//  Surf
//
//  Created by Sapan Bhuta on 6/21/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface History : NSObject
+ (NSDictionary *)layoutFrom:(NSDictionary *)site;
+ (NSString *)selected:(NSDictionary *)site;
+ (CGFloat)width:(NSDictionary *)site;
+ (CGFloat)height:(NSDictionary *)site;
@end
