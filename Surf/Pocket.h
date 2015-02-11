//
//  Pocket.h
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pocket : NSObject
- (void)getData;
+ (void)deletePocket:(NSString *)item_id;
+ (void)archivePocket:(NSString *)item_id;
@end
