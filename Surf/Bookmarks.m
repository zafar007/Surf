//
//  Bookmarks.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Bookmarks.h"

@implementation Bookmarks

+ (NSDictionary *)layoutFrom:(NSDictionary *)site;
{
    NSURL *url = [NSURL URLWithString:site[@"url"]];
    NSString *host = url.host;
    if ([host hasPrefix:@"www."])
    {
        host = [host substringFromIndex:4];
    }

    return @{@"simple":@YES,
             @"text":site[@"title"],
             @"subtext":host,
             @"Cell1Exist":@YES,
             @"Cell1Image":@"cross",
             @"Cell1Color":[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0],
             @"Cell1Mode":@1,
             };
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
