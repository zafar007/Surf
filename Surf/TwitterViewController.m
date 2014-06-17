//
//  TwitterViewController.m
//  Surf
//
//  Created by Sapan Bhuta on 6/6/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define CellIdentifier @"Cell"

#import "TwitterViewController.h"
#import "SBTableViewCell.h"
#import "Twitter.h"
#import "ReadSettingsViewController.h"

@interface TwitterViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property UITableView *tableView;
@property UICollectionView *buttons;
@property NSArray *buttonItems;
@property NSArray *tweets;
@end

@implementation TwitterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createButtons];
    [self createTable];
}

- (void)getTweets
{
    Twitter *twitter = [Twitter new];
    [twitter getTimeLine];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveTweets:) name:@"Twitter" object:nil];
}

- (void)saveTweets:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Twitter" object:nil];
    self.tweets = notification.object;
    [self.tableView reloadData];
}

- (void)createButtons
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                 target:self
                                                                                 action:@selector(unwind)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:cancelButton, nil];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                target:self
                                                                                action:@selector(add)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:addButton, nil];

    self.buttonItems = @[@"twitter",@"bookmarks",@"glasses",@"facebook",@"pinterest",@"hackernews",@"dribbble"];

    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.buttons = [[UICollectionView alloc] initWithFrame:CGRectMake(0,10,320,44)
                                                   collectionViewLayout:flow];
    [self.buttons registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    self.buttons.delegate = self;
    self.buttons.dataSource = self;
    self.buttons.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = self.buttons;
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

    NSDictionary *layoutData = [Twitter layoutFrom:self.tweets[indexPath.row]];
    [cell modifyCellLayoutWithData:layoutData];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SBTableViewCell heightForCellWithTweet:self.tweets[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlString = self.tweets[indexPath.row][@"entities"][@"urls"][0][@"expanded_url"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TwitterBack" object:urlString];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UICollectionView DataSource Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(32, 32);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.buttonItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [self makeButtonIn:cell forItem:indexPath.item];
    return cell;
}

- (void)makeButtonIn:(UICollectionViewCell *)cell forItem:(int)item
{
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImage *image = [UIImage imageNamed:self.buttonItems[item]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:self
               action:@selector(onButtonPress:)
      forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    button.frame = CGRectMake(cell.backgroundView.frame.origin.x,
                              cell.backgroundView.frame.origin.y,
                              cell.backgroundView.frame.size.width,
                              cell.backgroundView.frame.size.height);
    button.tag = item;
    button.frame = cell.bounds;
    [cell.contentView addSubview:button];
}

- (void)onButtonPress:(UIButton *)sender
{
    switch (sender.tag)
    {
        case 0:
            NSLog(@"Tweet");
            [self getTweets];
            break;

        case 1:
            NSLog(@"Bookmark");
            break;

        default:
            break;
    }
}

#pragma mark - Button Handling

- (void)unwind
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TwitterBack" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)add
{
    ReadSettingsViewController *settings = [ReadSettingsViewController new];
    [self presentViewController:settings animated:YES completion:nil];
}

#pragma mark - Landscape Layout Adjust

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.tableView.frame = CGRectMake(self.view.frame.origin.x,
                                          self.view.frame.origin.y,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height);
    }
    else
    {
        self.tableView.frame = CGRectMake(self.view.frame.origin.x,
                                          self.view.frame.origin.y,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height);
    }
}

@end