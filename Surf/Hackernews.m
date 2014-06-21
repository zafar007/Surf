//
//  Hackernews.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define kAPI @"http://api.ihackernews.com/page"

#import "Hackernews.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface Hackernews ()
@property NSMutableArray *posts;
@end

@implementation Hackernews

- (void)getData
{
    NSLog(@"Hackernews");
    self.posts = [NSMutableArray new];

    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kAPI]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (!connectionError)
         {
             NSDictionary *output = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
             NSArray *items = output[@"items"];

             for (NSDictionary *item in items)
             {
                 NSString *title = item[@"title"];
                 NSString *url = item[@"url"];
                 NSString *idnum = item[@"id"];
                 NSString *commentsCount = item[@"commentCount"];
                 NSString *points = item[@"points"];
                 NSString *postedAgo = item[@"postedAgo"];
                 NSString *postedBy = item[@"postedBy"];
                 NSDictionary *post = @{@"title":title,
                                        @"url":url,
                                        @"idnum":idnum,
                                        @"commentsCount":commentsCount,
                                        @"points":points,
                                        @"postedAgo":postedAgo,
                                        @"postedBy":postedBy};

                 [self.posts addObject:post];
             }

             [[NSNotificationCenter defaultCenter] postNotificationName:@"Hackernews" object:self.posts];
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] init];
             alert.title = @"Error Retrieving Data";
             alert.message = @"Please check your internet connection & for an app update (API might be broken)";
             [alert addButtonWithTitle:@"Dismiss"];
             [alert show];
         }
     }];
}

+ (NSDictionary *)layoutFrom:(NSDictionary *)post
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self width:post], [self height:post])];
    contentView.backgroundColor = [UIColor whiteColor];

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 0, 320-68-5, contentView.frame.size.height)];
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.origin.x+20,
                                                                  contentView.frame.size.height-.5,
                                                                  contentView.frame.size.width-20,
                                                                  .5)];

    NSURL *url = [NSURL URLWithString:post[@"url"]];
    NSString *host = url.host;
    if ([host hasPrefix:@"www."])
    {
        host = [host substringFromIndex:[@"www." length]];
    }

    textView.text = [NSString stringWithFormat:@"%@\n%@\n\n%@ points by %@\n%@ | %@ comments",post[@"title"], host, post[@"points"], post[@"postedBy"], post[@"postedAgo"], post[@"commentsCount"]];
    textView.font = [UIFont systemFontOfSize:13];
    textView.editable = NO;
    textView.selectable = NO;
    textView.userInteractionEnabled = NO;

    borderView.backgroundColor = [UIColor lightGrayColor];

    [contentView addSubview:textView];
    [contentView addSubview:borderView];

    return @{@"contentView":contentView};

}

+ (NSString *)selected:(NSDictionary *)post
{
    return post[@"url"];
}

+ (CGFloat)width:(NSDictionary *)post
{
    return 320;
}

+ (CGFloat)height:(NSDictionary *)post
{
    return 120;
}

@end