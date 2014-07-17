//
//  RSS.m
//  Surf
//
//  Created by Sapan Bhuta on 7/17/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "RSS.h"

@interface RSS ()
@property NSMutableArray *posts;
@end

@implementation RSS

- (void)getData:(NSString *)apiString
{
    NSLog(@"RSS");
    self.posts = [NSMutableArray new];

//    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:apiString]]
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
//     {
//         if (!connectionError)
//         {
//             NSDictionary *output = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
//             NSArray *hunts = output[@"hunts"];
//
//             for (NSDictionary *hunt in hunts)
//             {
//                 NSString *productLink = hunt[@"url"];
//                 NSString *title = hunt[@"title"];
//                 NSString *subtitle = hunt[@"tagline"];
//
//                 NSDictionary *post = @{@"link":productLink,
//                                        @"title":title,
//                                        @"subtitle":subtitle};
//
//                 [self.posts addObject:post];
//             }
//
//             [[NSNotificationCenter defaultCenter] postNotificationName:@"Rss" object:self.posts];
//         }
//         else
//         {
//             UIAlertView *alert = [[UIAlertView alloc] init];
//             alert.title = @"Error Retrieving Data";
//             alert.message = @"Please check your internet connection & for an app update (API might be broken)";
//             [alert addButtonWithTitle:@"Dismiss"];
//             [alert show];
//         }
//     }];
}

+ (NSDictionary *)layoutFrom:(NSDictionary *)post
{
    NSString *textLabel = post[@"title"];
    NSString *detailTextLabel = post[@"subtitle"];

    return @{
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
    return post[@"link"];
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
