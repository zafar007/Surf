//
//  Glasses.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "Cloud.h"

@implementation Cloud

- (void)getData
{
    NSLog(@"Cloud");
    NSArray *sites = [[NSUserDefaults standardUserDefaults] objectForKey:@"cloud"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Cloud" object:sites];
}

+ (NSDictionary *)layoutFrom:(NSDictionary *)site;
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    textView.editable = NO;
    textView.selectable = NO;
    textView.userInteractionEnabled = NO;

    NSURL *url = [NSURL URLWithString:site[@"url"]];
    NSString *host = url.host;
    if ([host hasPrefix:@"www."])
    {
        host = [host substringFromIndex:4];
    }
    textView.text = [NSString stringWithFormat:@"%@\n%@",site[@"title"],host];

    return @{@"contentView":textView};
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
