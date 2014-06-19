//
//  TwitterViewController.m
//  Surf
//
//  Created by Sapan Bhuta on 6/6/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define CellIdentifier @"Cell"

#import "ReadingViewController.h"
#import "SBTableViewCell.h"
#import "SettingsViewController.h"
#import "Twitter.h"
#import "Global.h"
#import "Feedly.h"
#import "Pocket.h"
#import "Instapaper.h"
#import "Readability.h"
#import "Facebook.h"
#import "Pinterest.h"
#import "Dribbble.h"
#import "Bookmarks.h"
#import "Glasses.h"
#import "Hackernews.h"
#import "Reddit.h"
#import "Producthunt.h"

@interface ReadingViewController () <UITableViewDelegate,
                                        UITableViewDataSource,
                                        UICollectionViewDataSource,
                                        UICollectionViewDelegateFlowLayout>
@property UITableView *tableView;
@property UICollectionView *buttons;
@property NSArray *buttonItems;
@property NSArray *data;
@property Twitter *twitter;
@property Global *global;
@property Feedly *feedly;
@property Pocket *pocket;
@property Instapaper *instapaper;
@property Readability *readability;
@property Facebook *facebook;
@property Pinterest *pinterest;
@property Dribbble *dribbble;
@property Bookmarks *bookmarks;
@property Glasses *glasses;
@property Hackernews *hackernews;
@property Reddit *reddit;
@property Producthunt *producthunt;
@end

@implementation ReadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.buttonItems = @[@"twitter",
                         @"global",
                         @"feedly",
                         @"pocket",
                         @"instapaper",
                         @"readability",
                         @"facebook",
                         @"pinterest",
                         @"dribbble",
                         @"bookmarks",
                         @"glasses",
                         @"hackernews",
                         @"reddit",
                         @"producthunt"];

    [self loadServiceObservers];
    [self createButtons];
    [self createTable];

    [[NSNotificationCenter defaultCenter] postNotificationName:self.buttonItems[0] object:nil];     //TEMPORARY
}

- (void)loadServiceObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTwitter) name:@"twitter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGlobal) name:@"global" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFeedly) name:@"feedly" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPocket) name:@"pocket" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadInstapaper) name:@"instapaper" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadReadability) name:@"readability" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFacebook) name:@"facebook" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPinterest) name:@"pinterest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDribbble) name:@"dribbble" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadBookmarks) name:@"bookmarks" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGlasses) name:@"glasses" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHackernews) name:@"hackernews" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadReddit) name:@"reddit" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProducthunt) name:@"producthunt" object:nil];
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
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[SBTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    NSDictionary *layoutData = [Twitter layoutFrom:self.data[indexPath.row]];
    [cell modifyCellLayoutWithData:layoutData];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SBTableViewCell heightForCellWithTweet:self.data[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlString = self.data[indexPath.row][@"entities"][@"urls"][0][@"expanded_url"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackFromReadVC" object:urlString];
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
    [self makeButtonIn:cell forItem:(int)indexPath.item];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:self.buttonItems[sender.tag] object:nil];
}

#pragma mark - Services

- (void)loadTwitter
{
    if (!self.twitter)
    {
        self.twitter = [Twitter new];
    }
    [self.twitter getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactTwitter:) name:@"Twitter" object:nil];
}

- (void)reactTwitter:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Twitter" object:nil];
    self.data = notification.object;
    [self.tableView reloadData];
}

- (void)loadGlobal
{
    if (!self.global)
    {
        self.global = [Global new];
    }
    [self.global getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactGlobal:) name:@"Global" object:nil];
}

- (void)reactGlobal:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Global" object:nil];
    self.data = notification.object;
    NSLog(@"data: %@",self.data);
    [self.tableView reloadData];
}

- (void)loadFeedly
{
    if (!self.feedly)
    {
        self.feedly = [Feedly new];
    }
    [self.feedly getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactFeedly:) name:@"Feedly" object:nil];
}

- (void)reactFeedly:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Feedly" object:nil];
    self.data = notification.object;
    [self.tableView reloadData];
}

- (void)loadPocket
{
    if (!self.pocket)
    {
        self.pocket = [Pocket new];
    }
    [self.pocket getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactPocket:) name:@"Pocket" object:nil];
}

- (void)reactPocket:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pocket" object:nil];
    self.data = notification.object;
    [self.tableView reloadData];
}

- (void)loadInstapaper
{
    if (!self.instapaper)
    {
        self.instapaper = [Instapaper new];
    }
    [self.instapaper getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactInstapaper:) name:@"Instapaper" object:nil];
}

- (void)reactInstapaper:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Instapaper" object:nil];
    self.data = notification.object;
    [self.tableView reloadData];
}

- (void)loadReadability
{
    if (!self.readability)
    {
        self.readability = [Readability new];
    }
    [self.readability getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactReadability:) name:@"Readability" object:nil];
}

- (void)reactReadability:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Readability" object:nil];
    self.data = notification.object;
    [self.tableView reloadData];
}

- (void)loadFacebook
{
    if (!self.facebook)
    {
        self.facebook = [Facebook new];
    }
    [self.facebook getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactFacebook:) name:@"Facebook" object:nil];
}

- (void)reactFacebook:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Facebook" object:nil];
    self.data = notification.object;
    [self.tableView reloadData];
}

- (void)loadPinterest
{
    if (!self.pinterest)
    {
        self.pinterest = [Pinterest new];
    }
    [self.pinterest getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactPinterest:) name:@"Pinterest" object:nil];
}

- (void)reactPinterest:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pinterest" object:nil];
    self.data = notification.object;
    [self.tableView reloadData];
}

- (void)loadDribbble
{
    if (!self.dribbble)
    {
        self.dribbble = [Dribbble new];
    }
    [self.dribbble getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactDribbble:) name:@"Dribbble" object:nil];
}

- (void)reactDribbble:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Dribbble" object:nil];
    self.data = notification.object;
    [self.tableView reloadData];
}

- (void)loadBookmarks
{
    if (!self.bookmarks)
    {
        self.bookmarks = [Bookmarks new];
    }
    [self.bookmarks getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactBookmarks:) name:@"Bookmarks" object:nil];
}

- (void)reactBookmarks:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Bookmarks" object:nil];
    self.data = notification.object;
    [self.tableView reloadData];
}

- (void)loadGlasses
{
    if (!self.glasses)
    {
        self.glasses = [Glasses new];
    }
    [self.glasses getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactGlasses:) name:@"Glasses" object:nil];
}

- (void)reactGlasses:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Glasses" object:nil];
    self.data = notification.object;
    [self.tableView reloadData];
}

- (void)loadHackernews
{
    if (!self.hackernews)
    {
        self.hackernews = [Hackernews new];
    }
    [self.hackernews getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactHackernews:) name:@"Hackernews" object:nil];
}

- (void)reactHackernews:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Hackernews" object:nil];
    self.data = notification.object;
    [self.tableView reloadData];
}

- (void)loadReddit
{
    if (!self.reddit)
    {
        self.reddit = [Reddit new];
    }
    [self.reddit getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactReddit:) name:@"Reddit" object:nil];
}

- (void)reactReddit:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Reddit" object:nil];
    self.data = notification.object;
    [self.tableView reloadData];
}

- (void)loadProducthunt
{
    if (!self.producthunt)
    {
        self.producthunt = [Producthunt new];
    }
    [self.producthunt getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactProducthunt:) name:@"Producthunt" object:nil];
}

- (void)reactProducthunt:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Producthunt" object:nil];
    self.data = notification.object;
    [self.tableView reloadData];
}

#pragma mark - Button Handling

- (void)unwind
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackFromReadVC" object:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)add
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [self presentViewController:navigationController animated:NO completion:nil];
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