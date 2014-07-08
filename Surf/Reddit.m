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
             NSArray *children = output[@"data"][@"children"];

             for (NSDictionary *child in children)
             {
                 //I'm dog sitting this derp monster this weekend (i.imgur.com)
                 //submitted 4 hours ago by someshooter to /r/aww
                 //points
                 //thumbnail


                 NSString *title = child[@"data"][@"title"];
                 NSString *url = child[@"data"][@"url"];
                 NSString *score = child[@"data"][@"score"];
                 NSString *author = child[@"data"][@"author"];
                 NSString *permalink = child[@"data"][@"permalink"];
                 NSString *thumbnail = child[@"data"][@"thumbnail"];

                 NSDictionary *post = @{@"title":title,
                                        @"url":url,
                                        @"score":score,
                                        @"author":author,
                                        @"permalink":permalink,
                                        @"thumbnail":thumbnail};

                 NSURL *urlF = [NSURL URLWithString:url];
                 NSString *host = urlF.host;
                 if (![host hasPrefix:@"www.reddit"])
                 {
                     [self.posts addObject:post];
                 }
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
//    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self width:post], [self height:post])];
//    contentView.backgroundColor = [UIColor whiteColor];
//
//    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(65, 0, 320-60, contentView.frame.size.height)];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,50,50)];
//    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.origin.x+10,
//                                                                  contentView.frame.size.height-.5,
//                                                                  contentView.frame.size.width-10,
//                                                                  .5)];

    NSURL *url = [NSURL URLWithString:post[@"url"]];
    NSString *host = url.host;
    if ([host hasPrefix:@"www."])
    {
        host = [host substringFromIndex:[@"www." length]];
    }
//    textView.text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",post[@"title"], post[@"author"], host, post[@"score"]];
//    textView.font = [UIFont systemFontOfSize:13];
//    textView.editable = NO;
//    textView.selectable = NO;
//    textView.userInteractionEnabled = NO;
//
//    borderView.backgroundColor = [UIColor lightGrayColor];
//
//    [imageView setImageWithURL:[NSURL URLWithString:post[@"thumbnail"]] placeholderImage:[UIImage imageNamed:@"bluewave"]];
//    imageView.center = CGPointMake(35, CGRectGetMidY(contentView.frame));
//    imageView.layer.masksToBounds = YES;
//
//    [contentView addSubview:textView];
//    [contentView addSubview:borderView];
//    [contentView addSubview:imageView];

    NSString *textLabel = post[@"title"];
    NSString *detailTextLabel = [NSString stringWithFormat:@"%@\n%@\n%@", post[@"author"], host, post[@"score"]];
    NSString *image = post[@"thumbnail"];

    return @{
             @"simple":@YES,
             @"text":textLabel,
             @"subtext":detailTextLabel,
             @"image":image,
//             @"contentView":contentView,
             @"Cell1Exist":@YES,
             @"Cell1Image":@"pocket-cell",
             @"Cell1Color":[UIColor colorWithRed:0.941 green:0.243 blue:0.337 alpha:1],
             @"Cell1Mode":@2,
             };

}

+ (NSString *)selected:(NSDictionary *)post
{
    return [NSString stringWithFormat:@"http://www.reddit.com%@",post[@"permalink"]];
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
