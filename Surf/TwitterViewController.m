//
//  TwitterViewController.m
//  Surf
//
//  Created by Sapan Bhuta on 6/6/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "TwitterViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
//#import <QuartzCore/QuartzCore.h>

@interface TwitterViewController () <UITableViewDelegate, UITableViewDataSource>
@property NSArray *dataSource;
@property NSMutableArray *tweets;
@end

@implementation TwitterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createButtons];
    [self createTable];
    [self getTimeLine];
}

- (void)createButtons
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                 target:self
                                                                                 action:@selector(unwind)];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:cancelButton, nil];
}

- (void)createTable
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                   self.view.frame.origin.y,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height)
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.view addSubview:self.tableView];
}

- (void)getTimeLine
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];

             if ([arrayOfAccounts count] > 0)
             {
                 ACAccount *twitterAccount = arrayOfAccounts.lastObject;
                 NSURL *requestURL = [NSURL URLWithString: @"https://api.twitter.com/1.1/statuses/home_timeline.json"];
                 NSDictionary *parameters = @{@"count" : @"200"};
                 SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                             requestMethod:SLRequestMethodGET
                                                                       URL:requestURL
                                                                parameters:parameters];
                 postRequest.account = twitterAccount;
                 [postRequest performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      self.dataSource = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                      [self filterTweetsForLinkedPosts];
                      if (self.tweets.count != 0)
                      {
                          dispatch_async(dispatch_get_main_queue(), ^{ [self.tableView reloadData]; });
                      }
                  }];
             }
         }
         else
         {
             // Handle failure to get account access
         }
     }
    ];
}

- (void)filterTweetsForLinkedPosts
{
    self.tweets = [NSMutableArray new];

    for (NSDictionary *tweet in self.dataSource)
    {
        NSArray *urls = tweet[@"entities"][@"urls"];

        if (urls.count)
        {
            [self.tweets addObject:tweet];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    NSDictionary *tweet = self.tweets[indexPath.row];
    NSDictionary *retweet = tweet[@"retweeted_status"];
    if (retweet)
    {
        tweet = retweet;
    }
    NSString *tweetText = tweet[@"text"];
    NSURL *url = [NSURL URLWithString:tweet[@"entities"][@"urls"][0][@"expanded_url"]];
    NSArray *indices = tweet[@"entities"][@"urls"][0][@"indices"];
    int index0 = [indices[0] intValue];
    int index1 = [indices[1] intValue];
    NSString *host = url.host;
    NSString *newTweetText = [tweetText stringByReplacingCharactersInRange:NSMakeRange(index0, index1-index0) withString:host];
    cell.textLabel.text = [self cleanup:newTweetText];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:tweet[@"user"][@"profile_image_url"]]]];
//    cell.imageView.layer.masksToBounds = YES;
//    cell.imageView.layer.cornerRadius = cell.imageView.frame.size.width / 2.0;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    if (retweet)
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\nRetweeted by: %@",tweet[@"user"][@"name"], self.tweets[indexPath.row][@"user"][@"name"]];
        cell.detailTextLabel.numberOfLines = 2;
    }
    else
    {
        cell.detailTextLabel.text = tweet[@"user"][@"name"];
    }

    return cell;
}

- (NSString *)cleanup:(NSString *)tweetText
{
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&apos;" withString:@"\'"];
    return tweetText;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    int A = cell.textLabel.frame.size.height;
//    int B = cell.detailTextLabel.frame.size.height;
//    return A+B;

    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlString = self.tweets[indexPath.row][@"entities"][@"urls"][0][@"expanded_url"];
    NSLog(@"%@", urlString);
    [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:@"twitterURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)unwind
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"twitterURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end