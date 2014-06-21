//
//  Reddit.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define kAPI @"http://www.reddit.com/hot.json"

#import "Reddit.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface Reddit ()
@property NSMutableArray *posts;
@end

@implementation Reddit

- (void)getData
{
    NSLog(@"Reddit");
    self.posts = [NSMutableArray new];

    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kAPI]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (!connectionError)
         {
             NSDictionary *output = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
             NSArray *children = output[@"children"];

             for (NSDictionary *child in children)
             {
                 //I'm dog sitting this derp monster this weekend (i.imgur.com)
                 //submitted 4 hours ago by someshooter to /r/aww
                 //points
                 //thumbnail


                 NSString *title = child[@"data"][@"title"];
                 NSString *url = child[@"data"][@"url"];
                 NSString *score = child[@"data"][@"score"];
                 NSString *time = child[@"data"][@"created_utc"];
                 NSString *author = child[@"data"][@"author"];
                 NSString *permalink = child[@"data"][@"permalink"];
                 NSString *thumbnail = child[@"data"][@"thumbnail"];

                 NSDictionary *post = @{@"title":title,
                                        @"url":url,
                                        @"score":score,
                                        @"time":time,
                                        @"author":author,
                                        @"permalink":permalink,
                                        @"thumbnail":thumbnail};

                 [self.posts addObject:post];
             }

             [[NSNotificationCenter defaultCenter] postNotificationName:@"Reddit" object:self.posts];
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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,48,48)];
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
