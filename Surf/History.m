//
//  History.m
//  Surf
//
//  Created by Sapan Bhuta on 6/21/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "History.h"

@implementation History

+ (NSDictionary *)layoutFrom:(NSDictionary *)site;
{
    NSURL *url = [NSURL URLWithString:site[@"url"]];
    NSString *host = url.host;
    if ([host hasPrefix:@"www."])
    {
        host = [host substringFromIndex:4];
    }

    return @{@"text":site[@"title"],
             @"subtext":host};
}

+ (NSString *)selected:(NSDictionary *)site;
{
    return site[@"url"];
}

+ (CGFloat)width:(NSDictionary *)site;
{
    return 320;
}

+ (CGFloat)height:(NSDictionary *)site;
{
    return 44;
}

@end
