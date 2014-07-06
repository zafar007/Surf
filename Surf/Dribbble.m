//
//  Dribbble.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define kAPI @"http://api.dribbble.com/shots/popular"
#define shotsPerRow 1

#import "Dribbble.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface Dribbble ()
@property NSMutableArray *posts;
@end

@implementation Dribbble

- (void)getData
{
    NSLog(@"Dribbble");
    self.posts = [NSMutableArray new];

    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kAPI]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (!connectionError)
         {
             NSDictionary *output = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
             NSArray *shots = output[@"shots"];

             for (NSDictionary *shot in shots)
             {
                 NSString *title = shot[@"title"];
                 NSString *subtitle = shot[@"description"];
                 NSString *author = shot[@"player"][@"name"];
                 NSString *shotLink = shot[@"url"];
                 NSString *imageLink = shot[@"image_teaser_url"];

                 NSDictionary *post = @{@"title":title,
                                        @"subtitle":subtitle,
                                        @"author":author,
                                        @"shotLink":shotLink,
                                        @"imageLink":imageLink};

                 [self.posts addObject:post];
             }

             [[NSNotificationCenter defaultCenter] postNotificationName:@"Dribbble" object:self.posts];
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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,contentView.frame.size.width,contentView.frame.size.height)];
    [imageView setImageWithURL:[NSURL URLWithString:post[@"imageLink"]] placeholderImage:[UIImage imageNamed:@"bluewave"]];
    [contentView addSubview:imageView];

    return @{@"contentView":contentView};
}

+ (NSString *)selected:(NSDictionary *)post
{
    return post[@"shotLink"];
}

+ (CGFloat)width:(NSDictionary *)post
{
    return (320/shotsPerRow);
}

+ (CGFloat)height:(NSDictionary *)post
{
    return (320/shotsPerRow)*152/202;
}

@end
