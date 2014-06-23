//
//  History.m
//  Surf
//
//  Created by Sapan Bhuta on 6/21/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "History.h"

@implementation History

- (void)getData
{
    NSLog(@"History");
    NSArray *sites = [[NSUserDefaults standardUserDefaults] objectForKey:@"history"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"History" object:sites];
}

+ (NSDictionary *)layoutFrom:(NSDictionary *)site;
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self width:site], [self height:site])];
    contentView.backgroundColor = [UIColor whiteColor];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 0, 300, 44)];
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.origin.x+20,
                                                                  contentView.frame.size.height-.5,
                                                                  contentView.frame.size.width-20,
                                                                  .5)];
    borderView.backgroundColor = [UIColor lightGrayColor];

    NSURL *url = [NSURL URLWithString:site[@"url"]];
    NSString *host = url.host;
    if ([host hasPrefix:@"www."])
    {
        host = [host substringFromIndex:4];
    }
    textView.text = [NSString stringWithFormat:@"%@\n%@",site[@"title"],host];
    textView.font = [UIFont systemFontOfSize:13];
    textView.editable = NO;
    textView.selectable = NO;
    textView.userInteractionEnabled = NO;

    [contentView addSubview:textView];
    [contentView addSubview:borderView];

    return @{@"contentView":contentView};
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
