//
//  Producthunt.m
//  Surf
//
//  Created by Sapan Bhuta on 6/19/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define kAPI @"http://salty-mountain-8993.herokuapp.com/today"

#import "Producthunt.h"

@interface Producthunt ()
@property NSMutableArray *posts;
@end

@implementation Producthunt

- (void)getData
{
    NSLog(@"Producthunt");
    self.posts = [NSMutableArray new];

    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kAPI]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (!connectionError)
         {
             NSDictionary *output = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
             NSArray *hunts = output[@"hunts"];

             for (NSDictionary *hunt in hunts)
             {
                 NSString *productLink = hunt[@"url"];
                 NSString *title = hunt[@"title"];
                 NSString *subtitle = hunt[@"tagline"];
                 NSString *commentLink = [NSString stringWithFormat:@"http://www.producthunt.com%@", hunt[@"permalink"]];

                 NSDictionary *post = @{@"productLink":productLink,
                                        @"title":title,
                                        @"subtitle":subtitle,
                                        @"commentLink":commentLink};

                 [self.posts addObject:post];
             }

             [[NSNotificationCenter defaultCenter] postNotificationName:@"Producthunt" object:self.posts];
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
//    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 0, 320-68-5, contentView.frame.size.height)];
//    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.origin.x+20,
//                                                                  contentView.frame.size.height-.5,
//                                                                  contentView.frame.size.width-20,
//                                                                  .5)];
//
//    textView.text = [NSString stringWithFormat:@"%@\n%@",post[@"title"],post[@"subtitle"]];
//    textView.font = [UIFont systemFontOfSize:13];
//    textView.editable = NO;
//    textView.selectable = NO;
//    textView.userInteractionEnabled = NO;
//
//    borderView.backgroundColor = [UIColor lightGrayColor];
//
//    [contentView addSubview:textView];
//    [contentView addSubview:borderView];

    NSString *textLabel = post[@"title"];
    NSString *detailTextLabel = post[@"subtitle"];

    return @{
//             @"contentView":contentView,
             @"simple":@YES,
             @"text":textLabel,
             @"subtext":detailTextLabel,
             @"Cell1Exist":@YES,
             @"Cell1Image":@"pocket-cell",
             @"Cell1Color":[UIColor colorWithRed:0.941 green:0.243 blue:0.337 alpha:1],
             @"Cell1Mode":@2
             };

}

+ (NSString *)selected:(NSDictionary *)post
{
    return post[@"productLink"];
}

+ (CGFloat)width:(NSDictionary *)post
{
    return 320;
}

+ (CGFloat)height:(NSDictionary *)post
{
    return 68;
}

@end
