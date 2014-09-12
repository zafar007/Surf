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
    [self RESTCALLP1];
}

- (void)RESTCALLP1
{
    NSString *apiKey = @"e9af2cf386088f8348d8b4b1077d437ff3b72eaa4133ae55a81f6ca9e4f02829";
    NSString *apiSecret = @"96d1a541080f78260044b228693e98d105fa9c3edd5150742ad6c31ae8baa0be";
    NSString *urlString = [NSString stringWithFormat:@"https://www.producthunt.com/v1/oauth/token"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    NSString *params = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=client_credentials",apiKey,apiSecret];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error)
         {
             NSLog(@"%@",error.localizedDescription);
         }
         else
         {
             NSDictionary *output = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"%@",output);
             NSString *authorization = [NSString stringWithFormat:@"Bearer %@",output[@"access_token"]];
             [self RESTCALLP2:authorization];
         }
     }];
}

- (void)RESTCALLP2:(NSString *)authorization
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.producthunt.com/v1/posts"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"GET";
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error)
         {
             NSLog(@"error: %@",error.localizedDescription);
         }
         else
         {
             NSDictionary *output2 = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"success: %@",output2);
             [self handleSuccess:output2[@"posts"]];
         }
     }];
}

- (void)handleSuccess:(NSArray *)posts
{
    for (NSDictionary *hunt in posts)
    {
        NSString *productLink = hunt[@"redirect_url"];
        NSString *title = hunt[@"name"];
        NSString *subtitle = hunt[@"tagline"];
        NSString *commentLink = hunt[@"discussion_url"];
        NSString *imageLink = hunt[@"screenshot_url"][@"300px"];

        NSDictionary *post = @{@"productLink":productLink,
                               @"title":title,
                               @"subtitle":subtitle,
                               @"commentLink":commentLink,
                               @"imageLink":imageLink};

        [self.posts addObject:post];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"Producthunt" object:self.posts];
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
