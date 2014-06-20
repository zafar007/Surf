//
//  Producthunt.m
//  Surf
//
//  Created by Sapan Bhuta on 6/19/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define kAPI @"http://hook-api.herokuapp.com/today"
//#define kAPI @"http://producthuntios.herokuapp.com/today"     //NOT WOKRING :(

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
             alert.message = @"Please check your internet connectionor for an app update (API might be broken)";
             [alert addButtonWithTitle:@"Dismiss"];
             [alert show];
         }
     }];
}

+ (NSDictionary *)layoutFrom:(NSDictionary *)post
{
    NSLog(@"%@",post);

    return @{@"textLabel":post[@"title"],
             @"detailTextLabel":post[@"subtitle"],
             @"numberOfLines":@0,
             @"imgUrlString":@""};
}

+ (NSString *)selected:(NSDictionary *)post
{
    return post[@"productLink"];
}

+ (CGFloat)height:(NSDictionary *)post
{
    return 120;
}

@end
