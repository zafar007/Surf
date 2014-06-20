//
//  Global.h
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Global : NSObject
- (void)getData;
+ (NSDictionary *)layoutFrom:(NSDictionary *)tweet;
+ (NSString *)selected:(NSDictionary *)tweet;
+ (CGFloat)height:(NSDictionary *)tweet;
@end
