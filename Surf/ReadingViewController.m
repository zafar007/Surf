//
//  TwitterViewController.m
//  Surf
//
//  Created by Sapan Bhuta on 6/6/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define CellIdentifier @"Cell"

#import "ReadingViewController.h"
#import "SettingsViewController.h"
#import "MCSwipeTableViewCell.h"
#import "Twitter.h"
#import "Global.h"
#import "Feedly.h"
#import "Pocket.h"
#import "Instapaper.h"
#import "Readability.h"
#import "Facebook.h"
#import "Dribbble.h"
#import "Designernews.h"
#import "Bookmarks.h"
#import "History.h"
#import "Hackernews.h"
#import "Reddit.h"
#import "Producthunt.h"
#import "Gmail.h"

@interface ReadingViewController () <
                                    UITableViewDataSource,
                                    UITableViewDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout,
                                    UIPickerViewDelegate,
                                    UIPickerViewDataSource,
                                    UIGestureRecognizerDelegate
                                    >
@property UITableView *tableView;
@property UICollectionView *collectionView;
@property UICollectionView *buttons;
@property UIPickerView *pickerView;
@property UIActivityIndicatorView *activity;
@property NSArray *buttonItems;
@property NSArray *data;
@property UISwipeGestureRecognizer *swipeLeft;

@property Class selectedClass;
@property Twitter *twitter;
@property Global *global;
@property Feedly *feedly;
@property Pocket *pocket;
@property Instapaper *instapaper;
@property Readability *readability;
@property Facebook *facebook;
@property Dribbble *dribbble;
@property Designernews *designernews;
@property Bookmarks *bookmarks;
@property History *history;
@property Hackernews *hackernews;
@property Reddit *reddit;
@property Producthunt *producthunt;
@property Gmail *gmail;
@end

@implementation ReadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadButtonItems];
    [self loadServiceObservers];
    [self createButtons];
//    [self createTableView];
    [self createCollectionView];
    [self createPicker];
    [self createGestures];
    [self createActivityIndicator];

    [self.activity startAnimating];
    [[NSNotificationCenter defaultCenter] postNotificationName:self.buttonItems[0] object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    [self loadButtonItems];
    [self.pickerView reloadAllComponents];
}

- (void)loadButtonItems
{
    self.buttonItems = [[NSUserDefaults standardUserDefaults] objectForKey:@"buttonsSome"];
    if (!self.buttonItems)
    {
        self.buttonItems = [[NSUserDefaults standardUserDefaults] objectForKey:@"buttonsFull"];
        [[NSUserDefaults standardUserDefaults] setObject:self.buttonItems forKey:@"buttonsSome"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDribbble) name:@"dribbble" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDesignernews) name:@"designernews" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadBookmarks) name:@"bookmarks" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHistory) name:@"history" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHackernews) name:@"hackernews" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadReddit) name:@"reddit" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProducthunt) name:@"producthunt" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGmail) name:@"gmail" object:nil];
}

- (void)createButtons
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                 target:self
                                                                                 action:@selector(unwind)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:cancelButton, nil];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                target:self
                                                                                action:@selector(settings)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:addButton, nil];
}

- (void)createTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                   self.view.frame.origin.y,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height)
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:self.tableView];
}

- (void)createCollectionView
{
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                             self.view.frame.origin.y,
                                                                             self.view.frame.size.width,
                                                                             self.view.frame.size.height)
                                             collectionViewLayout:flow];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CellPost"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.collectionView];
}

- (void)createPicker
{
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.backgroundColor = [UIColor clearColor];
    self.pickerView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.navigationItem.titleView = self.pickerView;
    self.pickerView.frame = CGRectMake(52, -52, 216, 162);  //to remove height error
    NSArray *subviews = self.pickerView.subviews;
    [subviews[1] setBackgroundColor:[UIColor clearColor]];
    [subviews[2] setBackgroundColor:[UIColor clearColor]];

}

- (void)createGestures
{
    self.swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeFromLeft:)];
    self.swipeLeft.delegate = self;
    self.swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.collectionView addGestureRecognizer:self.swipeLeft];
}

- (void)swipeFromLeft:(UISwipeGestureRecognizer *)sender
{
    [self unwind];
}

- (void)createActivityIndicator
{
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activity.center = self.collectionView.center;
    self.activity.hidesWhenStopped = YES;
    [self.collectionView addSubview:self.activity];
}

#pragma mark - UIPickerView Delegate Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.buttonItems.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIImage *image = [UIImage imageNamed:self.buttonItems[row]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setImage:image forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 32, 32);
    button.center = view.center;
    button.transform = CGAffineTransformMakeRotation(M_PI_2);

    return button;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    for (NSString *item in self.buttonItems)
    {
        if (![item isEqualToString:self.buttonItems[row]])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:[item capitalizedString] object:nil];
        }
    }

    [self.activity startAnimating];
    self.data = nil;
    [self.collectionView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:self.buttonItems[row] object:nil];
}

#pragma mark - UITableView DataSource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.selectedClass height:self.data[indexPath.item]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell"];
//    if (!cell)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TableCell"];
//    }
//

    //start MCSwipeTableViewCell
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell"];
    if (!cell)
    {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TableCell"];
    }

    // Configuring the views and colors.
    UIView *checkView = [self viewWithImageName:@"check"];
    UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];

    UIView *crossView = [self viewWithImageName:@"cross"];
    UIColor *redColor = [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];

    UIView *clockView = [self viewWithImageName:@"clock"];
    UIColor *yellowColor = [UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0];

    UIView *listView = [self viewWithImageName:@"list"];
    UIColor *brownColor = [UIColor colorWithRed:206.0 / 255.0 green:149.0 / 255.0 blue:98.0 / 255.0 alpha:1.0];

    // Adding gestures per state basis.
    [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Checkmark\" cell");
        [self deleteCell:cell];
    }];

    [cell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Cross\" cell");
        [self deleteCell:cell];
    }];

    [cell setSwipeGestureWithView:clockView color:yellowColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Clock\" cell");
        [self deleteCell:cell];
    }];

    [cell setSwipeGestureWithView:listView color:brownColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"List\" cell");
        [self deleteCell:cell];
    }];
    //end MCSwipeTableViewCell

    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    NSDictionary *layoutViews = [self.selectedClass layoutFrom:self.data[indexPath.row]];
    [cell.contentView addSubview:layoutViews[@"contentView"]];
    
    return cell;
}

- (UIView *)viewWithImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

- (void)deleteCell:(MCSwipeTableViewCell *)cell
{
    if (cell)
    {
//        _nbItems--;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSMutableArray *temp = [self.data mutableCopy];
        [temp removeObjectAtIndex:indexPath.row];
        self.data = [NSArray arrayWithArray:temp];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlString = [self.selectedClass selected:self.data[indexPath.row]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackFromReadVC" object:urlString];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView DataSource Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([self.selectedClass width:self.data[indexPath.item]],
                      [self.selectedClass height:self.data[indexPath.item]]);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellPost" forIndexPath:indexPath];

    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    NSDictionary *layoutViews = [self.selectedClass layoutFrom:self.data[indexPath.item]];
    [cell.contentView addSubview:layoutViews[@"contentView"]];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlString = [self.selectedClass selected:self.data[indexPath.item]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackFromReadVC" object:urlString];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    self.selectedClass = [Twitter class];
    [self.collectionView reloadData];
    [self.activity stopAnimating];
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
    self.selectedClass = [Global class];
    [self.collectionView reloadData];
    [self.activity stopAnimating];
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
    self.selectedClass = [Feedly class];
    [self.collectionView reloadData];
    [self.activity stopAnimating];
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
    self.selectedClass = [Pocket class];
    [self.collectionView reloadData];
//    [self.tableView reloadData];
    [self.activity stopAnimating];
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
    self.selectedClass = [Instapaper class];
    [self.collectionView reloadData];
    [self.activity stopAnimating];
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
    self.selectedClass = [Readability class];
    [self.collectionView reloadData];
    [self.activity stopAnimating];
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
    self.selectedClass = [Facebook class];
    [self.collectionView reloadData];
    [self.activity stopAnimating];
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
    self.selectedClass = [Dribbble class];
    [self.collectionView reloadData];
    [self.activity stopAnimating];
}

- (void)loadDesignernews
{
    if (!self.designernews)
    {
        self.designernews = [Designernews new];
    }
    [self.designernews getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactDesignernews:) name:@"Designernews" object:nil];
}

- (void)reactDesignernews:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Designernews" object:nil];
    self.data = notification.object;
    self.selectedClass = [Designernews class];
    [self.collectionView reloadData];
    [self.activity stopAnimating];
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
    self.selectedClass = [Bookmarks class];
    [self.collectionView reloadData];
    [self.activity stopAnimating];
}

- (void)loadHistory
{
    if (!self.history)
    {
        self.history = [History new];
    }
    [self.history getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactHistory:) name:@"History" object:nil];
}

- (void)reactHistory:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"History" object:nil];
    self.data = notification.object;
    self.selectedClass = [History class];
    [self.collectionView reloadData];
    [self.activity stopAnimating];
}

- (void)loadHackernews
{
    if (!self.hackernews)
    {
        self.hackernews = [Hackernews new];
    }
    [self.hackernews getData];
    self.selectedClass = [Hackernews class];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactHackernews:) name:@"Hackernews" object:nil];
}

- (void)reactHackernews:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Hackernews" object:nil];
    self.data = notification.object;
    [self.collectionView reloadData];
    [self.activity stopAnimating];
}

- (void)loadReddit
{
    if (!self.reddit)
    {
        self.reddit = [Reddit new];
    }
    [self.reddit getData];
    self.selectedClass = [Reddit class];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactReddit:) name:@"Reddit" object:nil];
}

- (void)reactReddit:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Reddit" object:nil];
    self.data = notification.object;
    [self.collectionView reloadData];
    [self.activity stopAnimating];
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
    self.selectedClass = [Producthunt class];
    [self.collectionView reloadData];
    [self.activity stopAnimating];
}

- (void)loadGmail
{
    if (!self.gmail)
    {
        self.gmail = [Gmail new];
    }
    [self.gmail getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactGmail:) name:@"Gmail" object:nil];
}

- (void)reactGmail:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Gmail" object:nil];
    self.data = notification.object;
    self.selectedClass = [Gmail class];
    [self.collectionView reloadData];
    [self.activity stopAnimating];
}

- (void)settings
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [self presentViewController:navigationController animated:NO completion:nil];
}

- (void)unwind
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackFromReadVC" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Landscape Layout Adjust

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.collectionView.center = CGPointMake(self.view.center.x, self.collectionView.center.y);
        self.activity.center = self.collectionView.center;
    }
    else
    {
        self.collectionView.center = CGPointMake(self.view.center.x, self.collectionView.center.y);
        self.activity.center = self.collectionView.center;
    }
}

@end