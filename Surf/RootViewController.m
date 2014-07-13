//
//  RootViewController.m
//  Surf
//
//  Created by Sapan Bhuta on 5/30/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define tabsOffset 20
#define showOffset 300
#define newTabAlpha .25
#define oldTabAlpha 1

#import "RootViewController.h"
#import "Tab.h"
#import "ReadingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SBCollectionViewCell.h"
#import "PocketAPI.h"
#import "MLPAutoCompleteTextField.h"
#import "MLPAutoCompleteTextFieldDelegate.h"
#import "OmnibarDataSource.h"
#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"
@import Twitter;
#import "FBShimmering/FBShimmeringView.h"

@interface RootViewController () <UITextFieldDelegate,
                                    UIWebViewDelegate,
                                    UIGestureRecognizerDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout,
                                    MLPAutoCompleteTextFieldDelegate,
                                    UIScrollViewDelegate,
                                    UIPickerViewDataSource,
                                    UIPickerViewDelegate>
@property UIButton *circleButton;
@property UIImageView *wallPaper;
@property UIView *toolsView;
@property UICollectionView *tabsCollectionView;
@property UIPickerView *tabsPickerView;
@property FBShimmeringView *shimmeringView;
@property OmnibarDataSource *omnibarDataSource;
//@property MLPAutoCompleteTextField *omnibar;
@property HTAutocompleteTextField *omnibar;
@property UIProgressView *progressBar;
@property NSMutableArray *tabs;
@property int currentTabIndex;
@property UIPanGestureRecognizer *pan;
@property UITapGestureRecognizer *tap;
@property UISwipeGestureRecognizer *swipeUp;
@property UISwipeGestureRecognizer *swipeDown;
@property UISwipeGestureRecognizer *swipeFromRight;
@property UISwipeGestureRecognizer *swipeFromLeft;
@property UILongPressGestureRecognizer *longPressOnPocket;
@property UILongPressGestureRecognizer *longPressOnStar;
@property BOOL showingTools;
@property BOOL doneLoading;
@property NSTimer *loadTimer;
@property Tab *thisWebView;
@property Tab *rightWebView;
@property Tab *leftWebView;
@property NSTimer *delayTimer;
@property UIButton *stopButton;
@property UIButton *refreshButton;
@property UIButton *readButton;
@property UIButton *addButton;
@property UIButton *backButton;
@property UIButton *forwardButton;
@property UIButton *shareButton;
@property UIButton *saveButton;
@property UIButton *starButton;
@property UIButton *twitterButton;
@property UIButton *facebookButton;
@property UIButton *mailButton;
@property UIButton *pocketButton;
@property UIButton *instapaperButton;
@property UIButton *readabilityButton;
@property ReadingViewController *readingViewController;
@property UINavigationController *readingNavController;
@property UIPageControl *pageControl;
@property NSTimer *buttonCheckTimer;
@end

@implementation RootViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self editView];
    [self createToolsView];
    [self createCircleButton];
    [self createTabsCollectionView];
    [self createButtons];
    [self createOmnibar];
    [self createProgressBar];
    [self createGestures];
    [self loadTabs];
    [self createPageControl];
//    [self createTabsPickerView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backFromReadVC:) name:@"BackFromReadVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTab:) name:@"RemoveTab" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentURL) name:@"CurrentURL" object:nil];

    self.buttonCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1/10 target:self selector:@selector(buttonCheck) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.showingTools)
    {
//        [self.omnibar becomeFirstResponder];
    }
    [[UIApplication sharedApplication]setStatusBarHidden:!self.showingTools withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self saveTabs];
}

#pragma mark - Setup Scene
- (void)editView
{
    self.wallPaper = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back"]];
    [self.view addSubview:self.wallPaper];
}

- (void)createCircleButton
{
    self.circleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.circleButton addTarget:self action:@selector(toggleTools) forControlEvents:UIControlEventTouchUpInside];
    [self.circleButton setImage:[UIImage imageNamed:@"circle-full"] forState:UIControlStateNormal];
    self.circleButton.frame = CGRectMake(20, 20, 32, 32);
//    self.circleButton.center = CGPointMake(20, 300);
    self.circleButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 50);
    [self.view addSubview:self.circleButton];
}

- (void)toggleTools
{
    if (!self.showingTools)
    {
        [self showTools];
    }
    else
    {
        [self showWeb];
    }
}

- (void)createToolsView
{
    self.toolsView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                              self.view.frame.origin.y,
                                                              self.view.frame.size.width,
                                                              self.view.frame.size.height)];
    self.toolsView.backgroundColor = [UIColor blackColor];
    self.toolsView.alpha = .85;
    self.showingTools = true;
    [self.view addSubview:self.toolsView];
}

- (void)createOmnibar
{
    CGRect omnibarFrame = CGRectMake(self.toolsView.frame.origin.x+20,          //20
                                     self.toolsView.frame.size.height/2-50,     //284
                                     self.toolsView.frame.size.width-(2*20),    //280
                                     2*25);

    self.omnibar = [[HTAutocompleteTextField alloc] initWithFrame:omnibarFrame];
//    self.omnibar = [[MLPAutoCompleteTextField alloc] initWithFrame:omnibarFrame];

    self.omnibar.delegate = self;
    self.omnibar.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.omnibar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.omnibar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.omnibar.keyboardType = UIKeyboardTypeEmailAddress;
    self.omnibar.returnKeyType = UIReturnKeyGo;
    self.omnibar.placeholder = @"search";
    self.omnibar.textColor = [UIColor lightGrayColor];
    self.omnibar.adjustsFontSizeToFitWidth = YES;
    self.omnibar.textAlignment = NSTextAlignmentLeft;
    self.omnibar.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
    [self.toolsView addSubview:self.omnibar];
//    [self.omnibar becomeFirstResponder];

    self.omnibar.autocompleteDataSource = [HTAutocompleteManager sharedManager];
    self.omnibar.autocompleteType = HTAutocompleteTypeWebSearch;
//    self.omnibarDataSource = [OmnibarDataSource new];
//    self.omnibar.autoCompleteDataSource = self.omnibarDataSource;
//    self.omnibar.autoCompleteDelegate = self;
//    self.omnibar.autoCompleteTableAppearsAsKeyboardAccessory = YES;
//    self.omnibar.autoCompleteTableViewHidden = ![[[NSUserDefaults standardUserDefaults] objectForKey:@"MLPAutoComplete"] boolValue];


    self.shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.omnibar.frame];
    self.shimmeringView.shimmering = YES;
    self.shimmeringView.shimmeringBeginFadeDuration = 0.3;
    self.shimmeringView.shimmeringOpacity = 0.3;
    [self.toolsView insertSubview:self.shimmeringView belowSubview:self.omnibar];

    UILabel *searchLabel = [[UILabel alloc] initWithFrame:self.shimmeringView.bounds];
    searchLabel.text = @"search";
    searchLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
    searchLabel.textColor = [UIColor whiteColor];
    searchLabel.textAlignment = NSTextAlignmentCenter;
    searchLabel.backgroundColor = [UIColor clearColor];

    self.shimmeringView.contentView = searchLabel;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tab *tab = self.tabs[self.currentTabIndex];
    tab.urlString = [self searchOrLoad:selectedString];
    self.omnibar.text = @"";
    [self loadPage:tab];
}

- (void)createProgressBar
{
    self.progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                       self.view.frame.origin.y,
                                                                       320,
                                                                       2)];
    self.progressBar.progressViewStyle = UIProgressViewStyleBar;
    self.progressBar.progress = 0;
    self.progressBar.progressTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.progressBar.tintColor = [UIColor grayColor];
    self.progressBar.hidden = YES;
    [self.view addSubview:self.progressBar];
    [self.view bringSubviewToFront:self.progressBar];
}

- (void)createTabsCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.tabsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                                 tabsOffset,
                                                                                 self.view.frame.size.width,
                                                                                 148)
                                                 collectionViewLayout:flowLayout];
    self.tabsCollectionView.dataSource = self;
    self.tabsCollectionView.delegate = self;
    self.tabsCollectionView.backgroundColor = [UIColor blackColor];
    [self.tabsCollectionView registerClass:[SBCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.toolsView addSubview:self.tabsCollectionView];
}

- (void)createTabsPickerView
{
    self.tabsPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.tabsPickerView.delegate = self;
    self.tabsPickerView.dataSource = self;
    self.tabsPickerView.backgroundColor = [UIColor whiteColor];
    self.tabsPickerView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.tabsPickerView.frame = CGRectMake(self.view.frame.origin.x,
                                           tabsOffset,
                                           self.view.frame.size.width,
                                           162);
//    NSArray *subviews = self.tabsPickerView.subviews;
//    [subviews[1] setBackgroundColor:[UIColor clearColor]];
//    [subviews[2] setBackgroundColor:[UIColor clearColor]];
    [self.toolsView addSubview:self.tabsPickerView];
}

- (void)createPageControl
{
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                       168,
                                                                       self.view.frame.size.width,
                                                                       20)];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.pageControl.backgroundColor = [UIColor blackColor];
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = self.tabs.count;
    [self.toolsView addSubview:self.pageControl];
}

#pragma mark - TwitterViewController Handling

- (void)showReadingLinks
{
    [self.omnibar resignFirstResponder]; //makes keyboard pop backup faster for some reason when returning from twitterVC
    if (!self.readingNavController)
    {
        self.readingViewController = [[ReadingViewController alloc] init];
        self.readingNavController = [[UINavigationController alloc] initWithRootViewController:self.readingViewController];
    }
    [self presentViewController:self.readingNavController animated:YES completion:nil];
}

- (void)backFromReadVC:(NSNotification *)notification
{
    NSString *urlString = notification.object;
    if (urlString)
    {
        if ([self.tabs.lastObject request])
        {
            [self addTab:urlString];
        }
        else
        {
            [self switchToTab:(int)self.tabs.count-1];
            [self.tabs.lastObject setUrlString:urlString];
            [self loadPage:self.tabs.lastObject];
        }
    }
}

#pragma mark - Gestures

- (void)createGestures
{
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.pan.delegate = self;
    [self.view addGestureRecognizer:self.pan];

    self.longPressOnPocket = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pocketAll:)];
    self.longPressOnPocket.delegate = self;
    [self.pocketButton addGestureRecognizer:self.longPressOnPocket];

    self.longPressOnStar = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bookmarkAll:)];
    self.longPressOnStar.delegate = self;
    [self.starButton addGestureRecognizer:self.longPressOnStar];
}

- (void)handlePan:(UIPanGestureRecognizer *)sender
{
    if (self.showingTools && [sender locationInView:self.view].y > showOffset && //[self.tabs[self.currentTabIndex] request] &&
        [sender translationInView:self.view].y < 0)
    {
        [self showWeb];
    }

    if (self.showingTools && [sender locationInView:self.view].y > showOffset && [sender translationInView:self.view].y > 0)
    {
        [self.omnibar resignFirstResponder];
    }

    if (!self.showingTools && ![self.tabs[self.currentTabIndex] request] && [sender translationInView:self.view].y > 0)
    {
        [self showTools];
    }

    if ([sender translationInView:self.view].x < 0)
    {
        if (sender.state == UIGestureRecognizerStateBegan)
        {
            NSLog(@"setup");
        }

        NSLog(@"translate based on x");

        if (sender.state == UIGestureRecognizerStateEnded)
        {
            NSLog(@"cleanup");
        }
    }
    else if ([sender translationInView:self.view].x > 0)
    {
        if (sender.state == UIGestureRecognizerStateBegan)
        {
            NSLog(@"setup");
        }

        NSLog(@"translate based on x");

        if (sender.state == UIGestureRecognizerStateEnded)
        {
            NSLog(@"cleanup");
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (!self.showingTools && scrollView.contentOffset.y <= 0 && [scrollView.panGestureRecognizer translationInView:self.view].y > 0)
    {
        [self showTools];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.showingTools && scrollView.contentOffset.y <= 0 && scrollView.panGestureRecognizer.state == 2)
    {
        [self showTools];
    }
}

#pragma mark - Tabs

- (void)loadTabs
{
    self.tabs = [[NSMutableArray alloc] init];

    NSArray *savedUrlStrings = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedTabs"];
    BOOL reloadOldTabsOnStart = [[[NSUserDefaults standardUserDefaults] objectForKey:@"reloadOldTabsOnStart"] boolValue];

    if (reloadOldTabsOnStart && savedUrlStrings && savedUrlStrings.count>0)
    {
        for (NSString *urlString in savedUrlStrings)
        {
            [self addTab:urlString];
        }
        [self showTools];
    }
    else
    {
        [self addTab:nil];
//        [self addTab:@"https://www.google.com"];
    }
}

- (void)saveTabs
{
    NSMutableArray *tempArrayOfUrlStrings = [[NSMutableArray alloc] init];

    for (Tab *tab in self.tabs)
    {
        if (tab.request.URL)
        {
            [tempArrayOfUrlStrings addObject:tab.request.URL.absoluteString];
        }
    }

    [[NSUserDefaults standardUserDefaults] setObject:tempArrayOfUrlStrings forKey:@"savedTabs"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addTab:(NSString *)urlString
{
    Tab *newTab = [[Tab alloc] init];
    newTab.delegate = self;
    newTab.scrollView.delegate = self;
    [self.tabs addObject:newTab];
    self.pageControl.numberOfPages = self.tabs.count;
    [self.tabsCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.tabs.count-1 inSection:0]]];

    [self switchToTab:(int)self.tabs.count-1];

    if([urlString isKindOfClass:[NSString class]])
    {
        newTab.urlString = [self searchOrLoad:urlString];
        [self loadPage:newTab];
    }
    else
    {
//        [self.omnibar becomeFirstResponder];
    }
}

- (void)switchToTab:(int)newTabIndex
{
    [self.tabs[self.currentTabIndex] removeFromSuperview];
    self.currentTabIndex = newTabIndex;
    Tab *tab = self.tabs[self.currentTabIndex];
    tab.frame = CGRectMake(self.view.frame.origin.x,
                           self.view.frame.origin.y+showOffset,
                           self.view.frame.size.width,
                           self.view.frame.size.height);
//    NSLog(@"%f",tab.transform.ty);
//    if (!tab.transform.ty)
//    {
//        tab.transform = CGAffineTransformMakeTranslation(0, showOffset);
//    }
    [self.view insertSubview:tab aboveSubview:self.toolsView];
    [self pingPageControlIndexPath:nil];
}

- (void)removeTab:(NSNotification *)notification
{
    [self endLoadingUI];

    UICollectionViewCell *cell = notification.object;
    NSIndexPath *path = [self.tabsCollectionView indexPathForCell:cell];
    Tab *tab = self.tabs[path.item];

    [tab removeFromSuperview];
    [self.tabs removeObject:tab];
    [cell removeFromSuperview];
    [self.tabsCollectionView deleteItemsAtIndexPaths:@[path]];
    self.currentTabIndex = 0;
    [self pingPageControlIndexPath:nil];
    self.pageControl.numberOfPages = self.tabs.count;

    if (self.tabs.count == 0)
    {
        [self addTab:nil];
    }
}

#pragma mark - UICollectionView DataSource/Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([self.tabs[indexPath.item] request])
//    {
//        [self.omnibar resignFirstResponder];
//    }
//    else
//    {
//        [self.omnibar becomeFirstResponder];
//    }
    [self switchToTab:(int)indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    [self pingTabsCollectionFrame];
    return self.tabs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SBCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    cell.backgroundView = [self.tabs[indexPath.item] screenshot];

//    if ([self.tabs[indexPath.item] request])
//    {
//        cell.backgroundView = [self.tabs[indexPath.item] screenshot];
//    }
//    else
//    {
//        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back"]];
//    }
    [self pingPageControlIndexPath:indexPath];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(80, 148);
}

#pragma mark - UIPickerView DataSource/Delegate Methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self switchToTab:(int)row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.tabs.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
//    for (UIView *view in view.subviews)
//    {
//        [view removeFromSuperview];
//    }

    UIView *screenshot;
    if ([self.tabs[row] request])
    {
        screenshot = [self.tabs[row] screenshot];
    }
    else
    {
        screenshot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back"]];
    }

    [view addSubview:screenshot];
    screenshot.frame = view.bounds;
    screenshot.center = view.center;
    screenshot.transform = CGAffineTransformMakeRotation(M_PI_2);
    return view;
}

#pragma mark - Page Control

- (void)pingPageControlIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath)
    {
        self.pageControl.currentPage = indexPath.item;
    }
    else
    {
        self.pageControl.currentPage = self.currentTabIndex;
    }
}

#pragma mark - UITextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.shimmeringView.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.omnibar.text isEqualToString:@""])
    {
        self.shimmeringView.hidden = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.omnibar resignFirstResponder];
    Tab *tab = self.tabs[self.currentTabIndex];
    tab.urlString = [self searchOrLoad:textField.text];
    self.omnibar.text = @"";
    self.shimmeringView.hidden = NO;
    [self loadPage:tab];
    return true;
}

#pragma mark - Handling User Search Query

-(NSString *)searchOrLoad:(NSString *)userInput
{
    NSString *checkedURL = [self isURL:userInput];
    return checkedURL ? checkedURL : [self googleSearchString:userInput];
}

-(NSString *)isURL:(NSString *)userInput
{
    NSArray *urlEndings = @[@".com",@".co",@".net",@".io",@".org",@".edu",@".to",@".ly",@".gov",@".eu",@".cn",@".mil"];

    NSString *workingInput = @"";

    if ([userInput hasPrefix:@"http://"] || [userInput hasPrefix:@"https://"])
    {
        workingInput = userInput;
    }
    else if ([userInput hasPrefix:@"www."])
    {
        workingInput = [@"http://" stringByAppendingString:userInput];
    }
    else if ([userInput hasPrefix:@"m."])
    {
        workingInput = [@"http://" stringByAppendingString:userInput];
    }
    else if ([userInput hasPrefix:@"mobile."])
    {
        workingInput = [@"http://" stringByAppendingString:userInput];
    }
    else
    {
        workingInput = [@"http://www." stringByAppendingString:userInput];
    }

    NSURL *url = [NSURL URLWithString:workingInput];

    for (NSString *extension in urlEndings)
    {
        if ([url.host hasSuffix:extension])
        {
            return workingInput;
        }
    }
    return nil;
}

-(NSString *)googleSearchString:(NSString *)userInput
{
    NSString *noSpaces = [self urlEncode:userInput];
    NSString *searchUrl = [NSString stringWithFormat:@"https://www.google.com/search?q=%@&cad=h", noSpaces];
    return searchUrl;
}

- (NSString *)urlEncode:(NSString *)unencodedString
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)unencodedString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 ));
    return encodedString;
}

#pragma mark - Loading Web Page & Hiding/Showing Views

- (void)loadPage:(Tab *)tab
{
    [tab loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tab.urlString]]];
    [self showWeb];
}

- (void)showWeb
{
    [self.omnibar resignFirstResponder];

    Tab *tab = self.tabs[self.currentTabIndex];
    tab.userInteractionEnabled = YES;
    [UIView animateWithDuration:.3 animations:^{
//        tab.transform = CGAffineTransformMakeTranslation(0, -showOffset);
        tab.transform = CGAffineTransformMakeTranslation(tab.transform.tx, tab.transform.ty-showOffset);
    }];

    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.showingTools = false;
}

- (void)showTools
{
//    [self.omnibar becomeFirstResponder];

    Tab *tab = self.tabs[self.currentTabIndex];
    tab.userInteractionEnabled = NO;
    [UIView animateWithDuration:.3 animations:^{
//        tab.transform = CGAffineTransformMakeTranslation(0, 0);
        tab.transform = CGAffineTransformMakeTranslation(tab.transform.tx, tab.transform.ty+showOffset);
    }];

    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    self.showingTools = true;

    if (tab.request)
    {
        [self updateScreenshotOf:tab];
    }
}

- (void)updateScreenshotOf:(Tab *)tab
{
    NSIndexPath *path = [NSIndexPath indexPathForItem:self.currentTabIndex inSection:0];
    UICollectionViewCell *cell = [self.tabsCollectionView cellForItemAtIndexPath:path];
    tab.screenshot = [tab snapshotViewAfterScreenUpdates:YES];
    cell.backgroundView = tab.screenshot;

    [self pingPageControlIndexPath:[NSIndexPath indexPathForItem:self.currentTabIndex inSection:0]];
}

#pragma mark - UIWebView Delegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.progressBar.hidden = NO;
    self.progressBar.progress = 0;
    self.doneLoading = false;
    self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:0.025
                                                      target:self
                                                    selector:@selector(timerCallback)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)timerCallback
{
    if (self.doneLoading)
    {
        self.progressBar.progress = 1;
    }
    else if (self.progressBar.progress < 0.75)
    {
        self.progressBar.progress += 0.01;
    }
}

- (void)animateProgressBarHide
{
    self.progressBar.progress = 1;
    [UIView transitionWithView:self.progressBar
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    self.progressBar.hidden = YES;
    self.doneLoading = true;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self endLoadingUI];
    [self pingHistory:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self endLoadingUI];
}

- (void)endLoadingUI
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self animateProgressBarHide];
}

#pragma mark - Landscape Layout Adjust

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        CGRect frame = CGRectMake(self.view.frame.origin.x,
                                  self.view.frame.origin.y,
                                  self.view.frame.size.width,
                                  self.view.frame.size.height);

        self.wallPaper.frame = frame;
        self.toolsView.frame = frame;
        [self.tabs[self.currentTabIndex] setFrame:frame];

//        self.omnibar.frame = CGRectMake(self.toolsView.frame.origin.x+20,          //20
//                                        self.toolsView.frame.size.height/2-50,     //284
//                                        self.toolsView.frame.size.width-(2*20),    //280
//                                        2*25);
//        self.pageControl.frame = CGRectMake(self.view.frame.origin.x,
//                                            188,
//                                            self.view.frame.size.width,
//                                            20);
//        [self pingTabsCollectionFrame];
    }
    else
    {
        CGRect frame = CGRectMake(self.view.frame.origin.x,
                                  self.view.frame.origin.y,
                                  self.view.frame.size.height,
                                  self.view.frame.size.width);

        self.wallPaper.frame = frame;
        self.toolsView.frame = frame;
        [self.tabs[self.currentTabIndex] setFrame:CGRectZero];

//        self.pageControl.frame = CGRectMake(self.view.frame.origin.x,
//                                            self.view.frame.size.width-168,
//                                            self.view.frame.size.height,
//                                            20);
//        [self pingTabsCollectionFrameLandscape];
    }
}


- (void)pingTabsCollectionFrame
{
    if (self.tabs.count*80 < self.view.frame.size.width)
    {
        self.tabsCollectionView.frame = CGRectMake(self.view.frame.size.width/2-(45*self.tabs.count)+5,
                                                   tabsOffset,
                                                   self.view.frame.size.width,
                                                   148);
    }
    else
    {
        self.tabsCollectionView.frame = CGRectMake(self.view.frame.origin.x,
                                                   tabsOffset,
                                                   self.view.frame.size.width,
                                                   148);
    }
}

- (void)pingTabsCollectionFrameLandscape
{
    if (self.tabs.count*80 < self.view.frame.size.height)
    {
        self.tabsCollectionView.frame = CGRectMake(self.view.frame.size.height/2-(45*self.tabs.count)+5,
                                                   self.view.frame.size.width - 148,
                                                   self.view.frame.size.height,
                                                   148);
    }
    else
    {
        self.tabsCollectionView.frame = CGRectMake(self.view.frame.origin.x,
                                                   self.view.frame.size.width - 148,
                                                   self.view.frame.size.height,
                                                   148);
    }
}

#pragma mark - Buttons

- (void)createButtons
{
    self.refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.refreshButton addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventTouchUpInside];
    [self.refreshButton setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    self.refreshButton.frame = CGRectMake(77, 17, 38, 38);
    self.refreshButton.center = CGPointMake(self.view.frame.size.width/2+50, self.view.frame.size.height/2-70);
    [self.toolsView addSubview:self.refreshButton];

    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton addTarget:self action:@selector(cancelPage) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    self.stopButton.frame = CGRectMake(80, 20, 32, 32);
    self.stopButton.center = CGPointMake(self.view.frame.size.width/2+50, self.view.frame.size.height/2-70);
    [self.toolsView addSubview:self.stopButton];

    self.readButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.readButton addTarget:self action:@selector(showReadingLinks) forControlEvents:UIControlEventTouchUpInside];
    [self.readButton setImage:[UIImage imageNamed:@"read"] forState:UIControlStateNormal];
    self.readButton.frame = CGRectMake(20, 20, 48, 48);
    self.readButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-70);
    [self.toolsView addSubview:self.readButton];

    self.addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addButton addTarget:self action:@selector(addTab:) forControlEvents:UIControlEventTouchUpInside];
    [self.addButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    self.addButton.frame = CGRectMake(20, 20, 32, 32);
    self.addButton.center = CGPointMake(self.view.frame.size.width/2-50, self.view.frame.size.height/2-70);
    [self.toolsView addSubview:self.addButton];

    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setImage:[UIImage imageNamed:@"goBack"] forState:UIControlStateNormal];
    self.backButton.frame = CGRectMake(20, 20, 32, 32);
    self.backButton.center = CGPointMake(self.view.frame.size.width/2-90, self.view.frame.size.height/2-70);
    [self.toolsView addSubview:self.backButton];

    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton addTarget:self action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton setImage:[UIImage imageNamed:@"goForward"] forState:UIControlStateNormal];
    self.forwardButton.frame = CGRectMake(20, 20, 32, 32);
    self.forwardButton.center = CGPointMake(self.view.frame.size.width/2+90, self.view.frame.size.height/2-70);
    [self.toolsView addSubview:self.forwardButton];



    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    self.shareButton.frame = CGRectMake(20, 20, 32, 32);
    self.shareButton.center = CGPointMake(self.view.frame.size.width/2-130, self.view.frame.size.height/2-70);
//    self.shareButton.center = CGPointMake(self.view.frame.size.width/2-50, self.view.frame.size.height/2+100);
    [self.toolsView addSubview:self.shareButton];

//    self.starButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [self.starButton addTarget:self action:@selector(bookmark) forControlEvents:UIControlEventTouchUpInside];
//    [self.starButton setImage:[UIImage imageNamed:@"star-1"] forState:UIControlStateNormal];
//    self.starButton.frame = CGRectMake(20, 20, 32, 32);
//    self.starButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2+100);
//    [self.toolsView addSubview:self.starButton];

    self.pocketButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.pocketButton addTarget:self action:@selector(pocket) forControlEvents:UIControlEventTouchUpInside];
    [self.pocketButton setImage:[UIImage imageNamed:@"pocket"] forState:UIControlStateNormal];
    self.pocketButton.frame = CGRectMake(20, 20, 32, 32);
    self.pocketButton.center = CGPointMake(self.view.frame.size.width/2+130, self.view.frame.size.height/2-70);
//    self.pocketButton.center = CGPointMake(self.view.frame.size.width/2+50, self.view.frame.size.height/2+100);
    [self.toolsView addSubview:self.pocketButton];

//    self.facebookButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [self.facebookButton addTarget:self action:@selector(facebook) forControlEvents:UIControlEventTouchUpInside];
//    [self.facebookButton setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
//    self.facebookButton.frame = CGRectMake(20, 20, 32, 32);
//    self.facebookButton.center = CGPointMake(self.view.frame.size.width/2-50, self.view.frame.size.height/2+150);
//    [self.toolsView addSubview:self.facebookButton];
//
//    self.twitterButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [self.twitterButton addTarget:self action:@selector(tweet) forControlEvents:UIControlEventTouchUpInside];
//    [self.twitterButton setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
//    self.twitterButton.frame = CGRectMake(20, 20, 32, 32);
//    self.twitterButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2+150);
//    [self.toolsView addSubview:self.twitterButton];
//
//    self.mailButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [self.mailButton addTarget:self action:@selector(mail) forControlEvents:UIControlEventTouchUpInside];
//    [self.mailButton setImage:[UIImage imageNamed:@"mail"] forState:UIControlStateNormal];
//    self.mailButton.frame = CGRectMake(20, 20, 32, 32);
//    self.mailButton.center = CGPointMake(self.view.frame.size.width/2+50, self.view.frame.size.height/2+150);
//    [self.toolsView addSubview:self.mailButton];
}

- (void)buttonCheck
{
    if (self.showingTools && ![self.tabs[self.currentTabIndex] request])
    {
        [self.tabs[self.currentTabIndex] setAlpha:newTabAlpha];
    }
    else
    {
        [self.tabs[self.currentTabIndex] setAlpha:oldTabAlpha];
    }

    [self.view bringSubviewToFront:self.circleButton];
    [self.view bringSubviewToFront:self.progressBar];

    if (![self.tabs[self.currentTabIndex] request])
    {
        self.refreshButton.enabled = NO;

        self.shareButton.enabled = NO;
        self.starButton.enabled = NO;
        self.pocketButton.enabled = NO;
        self.twitterButton.enabled = NO;
        self.facebookButton.enabled = NO;
        self.mailButton.enabled = NO;
    }
    else
    {
        self.refreshButton.enabled = YES;

        self.shareButton.enabled = YES;
        self.starButton.enabled = YES;
        self.pocketButton.enabled = YES;
        self.twitterButton.enabled = YES;
        self.facebookButton.enabled = YES;
        self.mailButton.enabled = YES;
    }
    [self checkBackForwardButtons];

    if ([self.tabs[self.currentTabIndex] isLoading])
    {
        self.refreshButton.hidden = YES;
        self.stopButton.hidden = NO;
    }
    else
    {
        self.refreshButton.hidden = NO;
        self.stopButton.hidden = YES;
    }
}

- (void)checkBackForwardButtons
{
    Tab *tab = self.tabs[self.currentTabIndex];
    self.backButton.enabled = [tab canGoBack];
    self.forwardButton.enabled = [tab canGoForward];
}

- (void)goBack
{
    [self.tabs[self.currentTabIndex] goBack];
}

- (void)goForward
{
    [self.tabs[self.currentTabIndex] goForward];
}

- (void)refreshPage
{
    [self.tabs[self.currentTabIndex] reload];
}

- (void)cancelPage
{
    [self.tabs[self.currentTabIndex] stopLoading];
}

- (void)pingHistory:(UIWebView *)webView
{
    NSArray *history = [[NSUserDefaults standardUserDefaults] objectForKey:@"history"];
    NSMutableArray *historyM = [NSMutableArray arrayWithArray:history];
    if (![history.lastObject[@"url"] isEqualToString:webView.request.URL.absoluteString])
    {
        [historyM addObject:@{@"url":webView.request.URL.absoluteString,
                              @"title":[webView stringByEvaluatingJavaScriptFromString:@"document.title"]}];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:historyM] forKey:@"history"];
}

#pragma mark - Tab Saving

- (void)pocket
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"pocketLoggedIn"])
    {
        [[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error)
         {
             if (!error)
             {
                 [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"pocketLoggedIn"];
                 [self pocket2:[self.tabs[self.currentTabIndex] request].URL];
             }
         }];
    }
    else
    {
        [self pocket2:[self.tabs[self.currentTabIndex] request].URL];
    }
}

- (void)pocket2:(NSURL *)url
{
    [[PocketAPI sharedAPI] saveURL:url
                           handler:^(PocketAPI *API, NSURL *URL, NSError *error)
    {
        if(!error)
        {
            [self showStatusBarMessage:@"Pocketed" hideAfter:1];
//            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Saved to Pocket!"
//                                                              message:nil
//                                                             delegate:nil
//                                                    cancelButtonTitle:@"Dismiss"
//                                                    otherButtonTitles:nil];
//            [message show];
        }
        else
        {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error connecting to Pocket"
                                                              message:nil
                                                             delegate:nil
                                                    cancelButtonTitle:@"Dismiss"
                                                    otherButtonTitles:nil];
            [message show];
        }
    }];
}

- (void)pocketAll:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        for (Tab *tab in self.tabs)
        {
            [self pocket2:tab.request.URL];
        }

        self.tabs = [NSMutableArray new];
        [self.tabsCollectionView reloadData];

        for (UIView *view in self.view.subviews)
        {
            if ([view isKindOfClass:[UIWebView class]])
            {
                [view removeFromSuperview];
            }
        }
        self.currentTabIndex = 0;
        [self addTab:nil];
    }
}

- (void)facebook
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        Tab *tab = self.tabs[self.currentTabIndex];
        NSString *title = [tab stringByEvaluatingJavaScriptFromString:@"document.title"];
        NSString *text = [@"Check out: " stringByAppendingString:title];
        NSURL *url = tab.request.URL;

        if (url)
        {
            SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [fbSheet setInitialText:text];
            [fbSheet addURL:url];
            [self presentViewController:fbSheet animated:YES completion:nil];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)tweet
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        Tab *tab = self.tabs[self.currentTabIndex];
        NSString *title = [tab stringByEvaluatingJavaScriptFromString:@"document.title"];
        NSString *text = [@"Check out: " stringByAppendingString:title];
        NSURL *url = tab.request.URL;

        if (url)
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:text];
            [tweetSheet addURL:url];
            [self presentViewController:tweetSheet animated:YES completion:nil];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)mail
{

}

- (void)bookmark
{
    Tab *tab = self.tabs[self.currentTabIndex];
    NSString *url = tab.request.URL.absoluteString;
    NSString *title = [tab stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (url)
    {
        NSArray *bookmarks = [[NSUserDefaults standardUserDefaults] objectForKey:@"bookmarks"];
        NSMutableArray *bookmarksM = [NSMutableArray arrayWithArray:bookmarks];
        [bookmarksM addObject:@{@"url":url,
                                @"title":title}];
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:bookmarksM] forKey:@"bookmarks"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self.starButton setImage:[UIImage imageNamed:@"star-2"] forState:UIControlStateNormal];
    }
}

- (void)bookmarkAll:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        for (Tab *tab in self.tabs)
        {
            NSString *url = tab.request.URL.absoluteString;
            NSString *title = [tab stringByEvaluatingJavaScriptFromString:@"document.title"];
            if (url)
            {
                NSArray *bookmarks = [[NSUserDefaults standardUserDefaults] objectForKey:@"bookmarks"];
                NSMutableArray *bookmarksM = [NSMutableArray arrayWithArray:bookmarks];
                [bookmarksM addObject:@{@"url":url,
                                        @"title":title}];
                [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:bookmarksM] forKey:@"bookmarks"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [self.starButton setImage:[UIImage imageNamed:@"star-2"] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)share
{
    Tab *tab = self.tabs[self.currentTabIndex];
    NSString *title = [tab stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *text = [@"Check out: " stringByAppendingString:title];
    NSURL *url = tab.request.URL;

    if (url)
    {
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[text, url]
                                                                                 applicationActivities:nil];

        controller.excludedActivityTypes = @[UIActivityTypeAddToReadingList,
                                             UIActivityTypeAssignToContact,
                                             UIActivityTypeSaveToCameraRoll,
                                             UIActivityTypePostToFlickr,
                                             UIActivityTypePostToVimeo];

        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)currentURL
{
    NSString *url = [self.tabs[self.currentTabIndex] request].URL.absoluteString;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"url" object:url];
}

-(void)showStatusBarMessage:(NSString *)message hideAfter:(NSTimeInterval)delay
{
    UILabel *label = [[UILabel alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];//[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    label.text = message;
    label.alpha = 0;
    [self.toolsView addSubview:label];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:delay animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:delay animations:^{
            label.alpha = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        }];
    }];
}

@end