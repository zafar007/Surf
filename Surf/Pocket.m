//
//  Pocket.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define kAPI @"https://getpocket.com/v3/get"

#import "Pocket.h"
#import "PocketAPI.h"

@interface Pocket ()
@property NSMutableArray *data;
@end

@implementation Pocket

- (void)getData
{
    NSLog(@"Pocket, %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"pocketLoggedIn"]);

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"pocketLoggedIn"])
    {
        [[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error)
        {
            if (!error)
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"pocketLoggedIn"];
                [self getPockets];
            }
        }];
    }
    else
    {
        [self getPockets];
    }
}

- (void)getPockets
{
    self.data = [NSMutableArray new];

//    NSMutableURLRequest *request = [NSMutableURLRequest requ];

//    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kAPI]]
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
//    {
//
//    }];

    NSString *apiMethod = @"https://getpocket.com/v3/get";
    PocketAPIHTTPMethod httpMethod = PocketAPIHTTPMethodPOST;
    NSDictionary *arguments = @{@"consumer_key":[[PocketAPI sharedAPI] consumerKey], @"access_token":@""};

    [[PocketAPI sharedAPI] callAPIMethod:apiMethod
                          withHTTPMethod:httpMethod
                               arguments:arguments
                                 handler: ^(PocketAPI *api, NSString *apiMethod,
                                            NSDictionary *response, NSError *error)
    {
        NSLog(@"RESPONSE: %@",response);
//        if (!error)
//        {
//            for (NSDictionary *hunt in response[@"data"])
//            {
//                NSString *productLink = hunt[@"url"];
//                NSString *title = hunt[@"title"];
//                NSString *subtitle = hunt[@"tagline"];
//                NSString *commentLink = [NSString stringWithFormat:@"http://www.producthunt.com%@", hunt[@"permalink"]];
//
//                NSDictionary *site = @{@"productLink":productLink,
//                                       @"title":title,
//                                       @"subtitle":subtitle,
//                                       @"commentLink":commentLink};
//
//                [self.data addObject:site];
//            }
//
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"Pocket" object:self.data];
//        }
//        else
//        {
//            UIAlertView *alert = [[UIAlertView alloc] init];
//            alert.title = @"Error Retrieving Data";
//            alert.message = @"Please check your internet connection & for an app update (API might be broken)";
//            [alert addButtonWithTitle:@"Dismiss"];
//            [alert show];
//        }
    }];
















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

                 [self.data addObject:post];
             }

             [[NSNotificationCenter defaultCenter] postNotificationName:@"Pocket" object:self.data];
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

    textView.text = [NSString stringWithFormat:@"%@\n%@",post[@"title"],post[@"subtitle"]];
    textView.font = [UIFont systemFontOfSize:13];
    textView.editable = NO;
    textView.selectable = NO;
    textView.userInteractionEnabled = NO;

    borderView.backgroundColor = [UIColor lightGrayColor];

    [contentView addSubview:textView];
    [contentView addSubview:borderView];

    return @{@"contentView":contentView};

}

+ (NSString *)selected:(NSDictionary *)site
{
    return site[@"productLink"];
}

+ (CGFloat)width:(NSDictionary *)site
{
    return 320;
}

+ (CGFloat)height:(NSDictionary *)site
{
    return 68;
}


@end
