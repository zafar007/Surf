//
//  RootViewController.m
//  Surf
//
//  Created by Sapan Bhuta on 5/30/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define tabsOffset 30
#define showOffset 320
#define newTabAlpha .25
#define oldTabAlpha 1
#define tabProportion 4

#import "ViewController.h"
#import "Tab.h"
#import "SBCollectionViewCell.h"
#import "PocketAPI.h"
#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"
#import "FBShimmering/FBShimmeringView.h"
#import <QuartzCore/QuartzCore.h>
@import Twitter;

@interface ViewController () <UITextFieldDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

//views
@property UIImageView *wallPaper;
@property UIView *toolsView;
@property UICollectionViewFlowLayout *flowLayout;
@property UICollectionView *tabsCollectionView;
@property UIPickerView *tabsPickerView;
@property FBShimmeringView *shimmeringView;
@property UILabel *searchLabel;
@property HTAutocompleteTextField *omnibar;
@property UIProgressView *progressBar;

//gestures
@property UIPanGestureRecognizer *pan;
@property UITapGestureRecognizer *tap;
@property UISwipeGestureRecognizer *swipeUp;
@property UISwipeGestureRecognizer *swipeDown;
@property UISwipeGestureRecognizer *swipeFromRight;
@property UISwipeGestureRecognizer *swipeFromLeft;
@property UILongPressGestureRecognizer *longPressOnPocket;
@property UILongPressGestureRecognizer *longPressOnStar;

//state checks
@property BOOL showingTools;
@property BOOL doneLoading;

//tabs
@property NSMutableArray *tabs;
@property int currentTabIndex;
@property Tab *thisWebView;
@property Tab *rightWebView;
@property Tab *leftWebView;

//buttons
@property UIButton *circleButton;
@property UIButton *stopButton;
@property UIButton *refreshButton;
@property UIButton *addButton;
@property UIButton *backButton;
@property UIButton *forwardButton;
@property UIButton *shareButton;
@property UIButton *twitterButton;
@property UIButton *pocketButton;

//timers
@property NSTimer *loadTimer;
@property NSTimer *delayTimer;
@property NSTimer *buttonCheckTimer;
@end

@implementation ViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
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
    [self adjustViewsToPortrait];
    self.buttonCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1/10 target:self selector:@selector(buttonCheck) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self saveTabs];
}

#pragma mark - Setup Scene
- (void)editView {
    UIColor *iconColor = [UIColor colorWithRed:88/255.0f green:86/255.0f blue:214/255.0f alpha:1.0f];
    self.view.backgroundColor = iconColor;
}

- (void)createCircleButton {
    self.circleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.circleButton addTarget:self action:@selector(toggleTools) forControlEvents:UIControlEventTouchUpInside];
    [self.circleButton setImage:[UIImage imageNamed:@"circle-full"] forState:UIControlStateNormal];
    self.circleButton.frame = CGRectMake(20, 20, 32, 32);
    self.circleButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 50);
    [self.view addSubview:self.circleButton];
}

- (void)createToolsView {
    self.toolsView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    self.toolsView.backgroundColor = [UIColor blackColor];
    self.toolsView.alpha = .85;
    self.showingTools = true;
    [self.view addSubview:self.toolsView];
}

- (void)createOmnibar {
    CGRect omnibarFrame = CGRectMake(self.toolsView.frame.origin.x+20, self.toolsView.frame.size.height/2-50, self.toolsView.frame.size.width-(2*20), 2*25);

    self.omnibar = [[HTAutocompleteTextField alloc] initWithFrame:omnibarFrame];
    self.omnibar.delegate = self;
    self.omnibar.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.omnibar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.omnibar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.omnibar.keyboardType = UIKeyboardTypeEmailAddress;
    self.omnibar.keyboardAppearance = UIKeyboardAppearanceDark;
    self.omnibar.returnKeyType = UIReturnKeyGo;
    self.omnibar.placeholder = @"search";
    self.omnibar.textColor = [UIColor lightGrayColor];
    self.omnibar.adjustsFontSizeToFitWidth = YES;
    self.omnibar.textAlignment = NSTextAlignmentLeft;
    self.omnibar.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
    [self.toolsView addSubview:self.omnibar];
    self.omnibar.autocompleteDataSource = [HTAutocompleteManager sharedManager];
    self.omnibar.autocompleteType = HTAutocompleteTypeWebSearch;

    self.shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.omnibar.frame];
    self.shimmeringView.shimmering = YES;
    self.shimmeringView.shimmeringBeginFadeDuration = 0.3;
    self.shimmeringView.shimmeringOpacity = 0.3;
    [self.toolsView insertSubview:self.shimmeringView belowSubview:self.omnibar];

    self.searchLabel = [[UILabel alloc] initWithFrame:self.shimmeringView.bounds];
    self.searchLabel.text = @"search";
    self.searchLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
    self.searchLabel.textColor = [UIColor whiteColor];
    self.searchLabel.textAlignment = NSTextAlignmentCenter;
    self.searchLabel.backgroundColor = [UIColor clearColor];

    self.shimmeringView.contentView = self.searchLabel;
}

- (void)createProgressBar {
    self.progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 320, 2)];
    self.progressBar.progressViewStyle = UIProgressViewStyleBar;
    self.progressBar.progress = 0;
    self.progressBar.progressTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.progressBar.tintColor = [UIColor grayColor];
    self.progressBar.hidden = YES;
    [self.view addSubview:self.progressBar];
    [self.view bringSubviewToFront:self.progressBar];
}

- (void)createTabsCollectionView {
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.tabsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    self.tabsCollectionView.dataSource = self;
    self.tabsCollectionView.delegate = self;
    self.tabsCollectionView.backgroundColor = [UIColor clearColor];
    [self.tabsCollectionView registerClass:[SBCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.toolsView addSubview:self.tabsCollectionView];
}

#pragma mark - Gestures

- (void)createGestures {
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.pan.delegate = self;
    [self.view addGestureRecognizer:self.pan];
    self.longPressOnPocket = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pocketAll:)];
    self.longPressOnPocket.delegate = self;
    [self.pocketButton addGestureRecognizer:self.longPressOnPocket];
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    int threshold;
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        threshold = showOffset;
    } else {
        threshold = showOffset - 200;
    }

    if (self.showingTools &&
        [sender locationInView:self.view].y > threshold &&
        [sender translationInView:self.view].y < 0) {
        [self showWeb];
    }

    if (self.showingTools &&
        [sender locationInView:self.view].y > threshold &&
        [sender translationInView:self.view].y > 0) {
        [self.omnibar resignFirstResponder];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!self.showingTools && scrollView.contentOffset.y <= 0 && [scrollView.panGestureRecognizer translationInView:self.view].y > 0) {
        [self showTools];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.showingTools && scrollView.contentOffset.y <= 0 && scrollView.panGestureRecognizer.state == 2) {
        [self showTools];
    }
}

#pragma mark - Tabs

- (void)loadTabs {
    self.tabs = [[NSMutableArray alloc] init];
    NSArray *savedUrlStrings = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedTabs"];
    BOOL reloadOldTabsOnStart = [[[NSUserDefaults standardUserDefaults] objectForKey:@"reloadOldTabsOnStart"] boolValue];
    if (reloadOldTabsOnStart && savedUrlStrings && savedUrlStrings.count>0) {
        for (NSString *urlString in savedUrlStrings) {
            [self addTab:urlString];
        }
        [self showTools];
    } else {
        [self addTab:nil];
    }
}

- (void)saveTabs {
    NSMutableArray *tempArrayOfUrlStrings = [[NSMutableArray alloc] init];
    for (Tab *tab in self.tabs) {
        if (tab.URL) {
            [tempArrayOfUrlStrings addObject:tab.URL.absoluteString];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:tempArrayOfUrlStrings forKey:@"savedTabs"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addTab:(NSString *)urlString {
    Tab *newTab = [[Tab alloc] init];
    newTab.scrollView.delegate = self;
    [self.tabs addObject:newTab];
    [self.tabsCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.tabs.count-1 inSection:0]]];

    [self.view insertSubview:self.tabs.lastObject aboveSubview:self.toolsView];
    [self switchToTab:(int)self.tabs.count-1];

    if([urlString isKindOfClass:[NSString class]]) {
        newTab.urlString = [self searchOrLoad:urlString];
        [self loadPage:newTab];
    } else {
        [self.omnibar becomeFirstResponder];
    }
}

- (void)switchToTab:(int)newTabIndex {
    [self.tabs[self.currentTabIndex] setHidden:YES];
    self.currentTabIndex = newTabIndex;
    Tab *tab = self.tabs[self.currentTabIndex];
    tab.frame = self.view.bounds;
    tab.transform = CGAffineTransformMakeTranslation(tab.transform.tx,tab.transform.ty+showOffset);
    tab.userInteractionEnabled = NO;
    tab.hidden = NO;
}

- (void)removeTab:(UICollectionViewCell *)cell {
    [self endLoadingUI];

    NSIndexPath *path = [self.tabsCollectionView indexPathForCell:cell];
    Tab *tab = self.tabs[path.item];

    [tab removeFromSuperview];
    [self.tabs removeObject:tab];
    [cell removeFromSuperview];
    [self.tabsCollectionView deleteItemsAtIndexPaths:@[path]];
    self.currentTabIndex = 0;

    if (self.tabs.count == 0) {
        [self addTab:nil];
    } else {
        [self switchToTab:0];
    }
}

#pragma mark - UICollectionView DataSource/Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.tabs[indexPath.item] URL] ? [self.omnibar resignFirstResponder] : [self.omnibar becomeFirstResponder];
    [self switchToTab:(int)indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tabs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SBCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundView = [self.tabs[indexPath.item] screenshot];
    [self.tabs[indexPath.item] URL] ? [cell setAlpha:oldTabAlpha] : [cell setAlpha:newTabAlpha];
    cell.vc = self;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width/tabProportion, self.view.frame.size.height/tabProportion);
}

#pragma mark - UITextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.shimmeringView.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.omnibar.text isEqualToString:@""]) {
        self.shimmeringView.hidden = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.omnibar resignFirstResponder];
    Tab *tab = self.tabs[self.currentTabIndex];
    tab.urlString = [self searchOrLoad:textField.text];
    self.omnibar.text = @"";
    self.shimmeringView.hidden = NO;
    [self loadPage:tab];
    return true;
}

#pragma mark - Handling User Search Query

- (NSString *)searchOrLoad:(NSString *)userInput {
    NSString *checkedURL = [self isURL:userInput];
    return checkedURL ? checkedURL : [self googleSearchString:userInput];
}

-(NSString *)isURL:(NSString *)userInput {
    NSArray *urlEndings = @[@".com",@".co",@".net",@".io",@".org",@".edu",@".to",@".ly",@".gov",@".eu",@".cn",@".mil",@".gl"];
    NSString *workingInput = @"";

    if ([userInput hasPrefix:@"http://"] || [userInput hasPrefix:@"https://"]) {
        workingInput = userInput;
    } else if ([userInput hasPrefix:@"www."]) {
        workingInput = [@"http://" stringByAppendingString:userInput];
    } else if ([userInput hasPrefix:@"m."]) {
        workingInput = [@"http://" stringByAppendingString:userInput];
    } else if ([userInput hasPrefix:@"mobile."]) {
        workingInput = [@"http://" stringByAppendingString:userInput];
    } else {
        workingInput = [@"http://www." stringByAppendingString:userInput];
    }

    NSURL *url = [NSURL URLWithString:workingInput];
    for (NSString *extension in urlEndings) {
        if ([url.host hasSuffix:extension]) {
            return workingInput;
        }
    }
    return nil;
}

- (NSString *)googleSearchString:(NSString *)userInput {
    NSString *noSpaces = [self urlEncode:userInput];
    NSString *searchUrl = [NSString stringWithFormat:@"https://www.google.com/search?q=%@&cad=h", noSpaces];
    return searchUrl;
}

- (NSString *)urlEncode:(NSString *)unencodedString {
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)unencodedString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 ));
    return encodedString;
}

#pragma mark - Loading Web Page & Hiding/Showing Views

- (void)loadPage:(Tab *)tab {
    NSLog(@"URL %@", tab.urlString);
    NSLog(@"TAB %@", tab);
    [tab loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tab.urlString]]];
    [self showWeb];
}

- (void)showWeb {
    [self.omnibar resignFirstResponder];

    Tab *tab = self.tabs[self.currentTabIndex];
    tab.userInteractionEnabled = YES;
    [UIView animateWithDuration:.3 animations:^{
        tab.transform = CGAffineTransformMakeTranslation(tab.transform.tx, tab.transform.ty-showOffset);
    }];

    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.showingTools = false;
}

- (void)showTools {
    Tab *tab = self.tabs[self.currentTabIndex];
    tab.userInteractionEnabled = NO;
    [UIView animateWithDuration:.3 animations:^{
        tab.transform = CGAffineTransformMakeTranslation(tab.transform.tx, tab.transform.ty+showOffset);
    }];

    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    self.showingTools = true;

    [self updateScreenshotOf:tab];
//    [self updateScreenshots];
}

- (void)updateScreenshots {
    for (Tab *tab in self.tabs) {
        UIView *view = [tab snapshotViewAfterScreenUpdates:YES];
        tab.screenshot = view;
    }
    for (UICollectionViewCell *cell in self.tabsCollectionView.visibleCells) {
        NSIndexPath *indexPath = [self.tabsCollectionView indexPathForCell:cell];
        int index = (int)indexPath.item;
        cell.backgroundView = [self.tabs[index] screenshot];
    }
}

- (void)updateScreenshotOf:(Tab *)tab {
    tab.screenshot = [tab snapshotViewAfterScreenUpdates:YES];
    NSIndexPath *path = [NSIndexPath indexPathForItem:self.currentTabIndex inSection:0];
    UICollectionViewCell *cell = [self.tabsCollectionView cellForItemAtIndexPath:path];
    cell.backgroundView = tab.screenshot;
}

- (void)toggleTools {
    !self.showingTools ? [self showTools] : [self showWeb];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.subtype == UIEventSubtypeMotionShake) {
        [self toggleTools];
    }
}

#pragma mark - UIWebView Delegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.progressBar.hidden = NO;
    self.progressBar.progress = 0;
    self.doneLoading = false;
    self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}

- (void)timerCallback {
    if (self.doneLoading) {
        self.progressBar.progress = 1;
    } else if (self.progressBar.progress < 0.75) {
        self.progressBar.progress += 0.01;
    }
}

- (void)animateProgressBarHide {
    self.progressBar.progress = 1;
    [UIView transitionWithView:self.progressBar duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];
    self.progressBar.hidden = YES;
    self.doneLoading = true;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self endLoadingUI];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self endLoadingUI];
}

- (void)endLoadingUI {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self animateProgressBarHide];
}

#pragma mark - Landscape Layout Adjust

- (void)adjustViewsToPortrait {
    CGRect frame = self.view.bounds;
    self.wallPaper.frame = frame;
    self.toolsView.frame = frame;
    Tab *tab = self.tabs[self.currentTabIndex];
    tab.frame = CGRectMake(tab.frame.origin.x, tab.frame.origin.y, frame.size.width, frame.size.height);
    self.tabsCollectionView.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, 148+2*tabsOffset);
    self.tabsCollectionView.hidden = NO;
    self.omnibar.frame = CGRectMake(self.toolsView.frame.origin.x+20, showOffset-66, self.omnibar.frame.size.width, self.omnibar.frame.size.height);
    self.shimmeringView.frame = self.omnibar.frame;
    self.searchLabel.frame = self.shimmeringView.bounds;
    self.twitterButton.center = CGPointMake(frame.size.width/2,     showOffset-86);
    self.addButton.center = CGPointMake(frame.size.width/2-50,      showOffset-86);
    self.backButton.center = CGPointMake(frame.size.width/2-90,     showOffset-86);
    self.refreshButton.center = CGPointMake(frame.size.width/2+50,  showOffset-86);
    self.stopButton.center = CGPointMake(frame.size.width/2+50,     showOffset-86);
    self.forwardButton.center = CGPointMake(frame.size.width/2+90,  showOffset-86);
    self.shareButton.center = CGPointMake(frame.size.width/2-130,   showOffset-86);
    self.pocketButton.center = CGPointMake(frame.size.width/2+130,  showOffset-86);
}

#pragma mark - Buttons

- (void)createButtons {
    self.refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.refreshButton addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventTouchUpInside];
    [self.refreshButton setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    self.refreshButton.frame = CGRectMake(77, 17, 38, 38);
    self.refreshButton.tintColor = [UIColor whiteColor];
    [self.toolsView addSubview:self.refreshButton];

    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton addTarget:self action:@selector(cancelPage) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    self.stopButton.frame = CGRectMake(80, 20, 32, 32);
    self.stopButton.tintColor = [UIColor whiteColor];
    [self.toolsView addSubview:self.stopButton];

    self.addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addButton addTarget:self action:@selector(addTab:) forControlEvents:UIControlEventTouchUpInside];
    [self.addButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    self.addButton.frame = CGRectMake(20, 20, 32, 32);
    self.addButton.tintColor = [UIColor whiteColor];
    [self.toolsView addSubview:self.addButton];

    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setImage:[UIImage imageNamed:@"goBack"] forState:UIControlStateNormal];
    self.backButton.frame = CGRectMake(20, 20, 32, 32);
    self.backButton.tintColor = [UIColor whiteColor];
    [self.toolsView addSubview:self.backButton];

    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton addTarget:self action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton setImage:[UIImage imageNamed:@"goForward"] forState:UIControlStateNormal];
    self.forwardButton.frame = CGRectMake(20, 20, 32, 32);
    self.forwardButton.tintColor = [UIColor whiteColor];
    [self.toolsView addSubview:self.forwardButton];

    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    self.shareButton.frame = CGRectMake(20, 20, 32, 32);
    self.shareButton.tintColor = [UIColor whiteColor];
    [self.toolsView addSubview:self.shareButton];

    self.pocketButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.pocketButton addTarget:self action:@selector(pocket) forControlEvents:UIControlEventTouchUpInside];
    [self.pocketButton setImage:[UIImage imageNamed:@"pocket"] forState:UIControlStateNormal];
    self.pocketButton.frame = CGRectMake(20, 20, 32, 32);
    self.pocketButton.tintColor = [UIColor whiteColor];
    [self.toolsView addSubview:self.pocketButton];

    self.twitterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.twitterButton addTarget:self action:@selector(tweet) forControlEvents:UIControlEventTouchUpInside];
    [self.twitterButton setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
    self.twitterButton.frame = CGRectMake(20, 20, 32, 32);
    self.twitterButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2+150);
    [self.toolsView addSubview:self.twitterButton];
}

- (void)buttonCheck {
    [self.view bringSubviewToFront:self.circleButton];
    [self.view bringSubviewToFront:self.progressBar];

    for (UICollectionViewCell *cell in self.tabsCollectionView.visibleCells) {
        if ([self.tabs[[self.tabsCollectionView indexPathForCell:cell].item] URL]) {
            cell.alpha = oldTabAlpha;
        } else {
            cell.alpha = newTabAlpha;
        }
    }

    if (![self.tabs[self.currentTabIndex] URL]) {
        [self.tabs[self.currentTabIndex] setAlpha:newTabAlpha];
        self.refreshButton.enabled = NO;
        self.shareButton.enabled = NO;
        self.pocketButton.enabled = NO;
        self.twitterButton.enabled = NO;
    } else {
        [self.tabs[self.currentTabIndex] setAlpha:oldTabAlpha];
        self.refreshButton.enabled = YES;
        self.shareButton.enabled = YES;
        self.pocketButton.enabled = YES;
        self.twitterButton.enabled = YES;
    }

    self.backButton.enabled = [self.tabs[self.currentTabIndex] canGoBack];
    self.forwardButton.enabled = [self.tabs[self.currentTabIndex] canGoForward];
    self.refreshButton.hidden = [self.tabs[self.currentTabIndex] isLoading];
    self.stopButton.hidden = !([self.tabs[self.currentTabIndex] isLoading]);
    self.pocketButton.hidden = !((BOOL)[[NSUserDefaults standardUserDefaults] objectForKey:@"pocketLoggedIn"]);
}

- (void)goBack {
    [(Tab*)self.tabs[self.currentTabIndex] goBack];
}
- (void)goForward {
    [(Tab*)self.tabs[self.currentTabIndex] goForward];
}
- (void)refreshPage {
    [(Tab*)self.tabs[self.currentTabIndex] reload];
}
- (void)cancelPage {
    [(Tab*)self.tabs[self.currentTabIndex] stopLoading];
}

#pragma mark - Tab Saving

- (void)pocket {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"pocketLoggedIn"]) {
        [[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error) {
             if (!error) {
                 [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"pocketLoggedIn"];
                 [self pocket2:[self.tabs[self.currentTabIndex] URL]];
             }
         }];
    } else {
        [self pocket2:[self.tabs[self.currentTabIndex] URL]];
    }
}

- (void)pocket2:(NSURL *)url {
    [[PocketAPI sharedAPI] saveURL:url
                           handler:^(PocketAPI *API, NSURL *URL, NSError *error) {
        if(!error) {
            [self showStatusBarMessage:@"Pocketed" hideAfter:1];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error connecting to Pocket" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
        }
    }];
}

- (void)pocketAll:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        for (Tab *tab in self.tabs) {
            [self pocket2:tab.URL];
        }

        self.tabs = [NSMutableArray new];
        [self.tabsCollectionView reloadData];

        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[UIWebView class]]) {
                [view removeFromSuperview];
            }
        }
        self.currentTabIndex = 0;
        [self addTab:nil];
    }
}

- (void)tweet {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        Tab *tab = self.tabs[self.currentTabIndex];
        NSURL *url = tab.URL;

        if (url) {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:@""];
            [tweetSheet addURL:url];
            [self presentViewController:tweetSheet animated:YES completion:nil];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)share {
    Tab *tab = self.tabs[self.currentTabIndex];
    NSURL *url = tab.URL;

    if (url) {
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
        controller.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)currentURL {
    NSString *url = [self.tabs[self.currentTabIndex] URL].absoluteString;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"url" object:url];
}

- (void)showStatusBarMessage:(NSString *)message hideAfter:(NSTimeInterval)delay {
    UILabel *label = [[UILabel alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end