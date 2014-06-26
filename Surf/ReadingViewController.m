//
//  TwitterViewController.m
//  Surf
//
//  Created by Sapan Bhuta on 6/6/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define CellIdentifier @"Cell"

#import "ReadingViewController.h"
#import "SBReadCollectionViewCell.h"
#import "SettingsViewController.h"
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
#import "Cloud.h"
#import "History.h"
#import "Hackernews.h"
#import "Reddit.h"
#import "Producthunt.h"

@interface ReadingViewController () <UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout,
                                    UIPickerViewDelegate,
                                    UIPickerViewDataSource,
                                    UIGestureRecognizerDelegate>
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
@property Cloud *cloud;
@property History *history;
@property Hackernews *hackernews;
@property Reddit *reddit;
@property Producthunt *producthunt;
@end

@implementation ReadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadButtonItems];
    [self loadServiceObservers];
    [self createButtons];
    [self createCells];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCloud) name:@"cloud" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHistory) name:@"history" object:nil];
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
                                                                                action:@selector(settings)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:addButton, nil];
}

- (void)createCells
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
    [self.collectionView registerClass:[SBReadCollectionViewCell class] forCellWithReuseIdentifier:@"CellPost"];
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
//    for (NSString *item in self.buttonItems)
//    {
//        if (![item isEqualToString:self.buttonItems[row]])
//        {
//            [[NSNotificationCenter defaultCenter] removeObserver:self name:item object:nil];
//        }
//    }

    [self.activity startAnimating];
    self.data = nil;
    [self.collectionView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:self.buttonItems[row] object:nil];
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
    SBReadCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellPost" forIndexPath:indexPath];
    [cell modifyCellLayoutWith:[self.selectedClass layoutFrom:self.data[indexPath.item]]];
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

- (void)loadCloud
{
    if (!self.cloud)
    {
        self.cloud = [Cloud new];
    }
    [self.cloud getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactCloud:) name:@"Cloud" object:nil];
}

- (void)reactCloud:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Cloud" object:nil];
    self.data = notification.object;
    self.selectedClass = [Cloud class];
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