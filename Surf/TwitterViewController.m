//
//  TwitterViewController.m
//  Surf
//
//  Created by Sapan Bhuta on 6/6/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define CellIdentifier @"Cell"

#import "TwitterViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "SBTableViewCell.h"

@interface TwitterViewController () <UITableViewDelegate, UITableViewDataSource>
@property NSArray *dataSource;
@property NSMutableArray *tweets;
@property UITableViewCell *cellHolder;
@end

@implementation TwitterViewController

- (id)init
{
    if (self = [super init])
    {
        [self getTimeLine];     //moved from below [self createTable]; in viewDidLoad for faster tweet fetching
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createButtons];
    [self createTable];
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
    SBTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[SBTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    [cell layoutWithTweetFrom:self.tweets AtIndexPath:indexPath];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SBTableViewCell heightForCellWithTweet:self.tweets[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlString = self.tweets[indexPath.row][@"entities"][@"urls"][0][@"expanded_url"];
    NSLog(@"%@", urlString);
    [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:@"twitterURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)unwind
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"twitterURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end