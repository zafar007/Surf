//
//  RootViewController.m
//  Surf
//
//  Created by Sapan Bhuta on 5/30/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "RootViewController.h"
#import "Tab.h"
#import "TwitterViewController.h"

@interface RootViewController () <UITextFieldDelegate,
                                    UIWebViewDelegate,
                                    UIGestureRecognizerDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout>
@property UIView *toolsView;
@property UICollectionView *tabsCollectionView;
@property UITextField *omnibar;
@property UIProgressView *progressBar;
@property NSMutableArray *tabs;
@property int currentTabIndex;
@property CGRect omnnibarFrame;
@property UITapGestureRecognizer *tap;
@property UISwipeGestureRecognizer *swipeUp;
@property UISwipeGestureRecognizer *swipeDown;
@property UISwipeGestureRecognizer *swipeFromRight;
@property UISwipeGestureRecognizer *swipeFromLeft;
@property UIScreenEdgePanGestureRecognizer *edgeSwipeFromRight;
@property UIScreenEdgePanGestureRecognizer *edgeswipeFromLeft;
@property BOOL showingTools;
@property BOOL doneLoading;
@property NSTimer *loadTimer;
@property UIView *backgroundView;
@property UIView *currentScreenshot;
@property UIView *pastScreenshot;
@property UIView *futureScreenshot;
@property NSTimer *delayTimer;
@property UIButton *shareButton;
@property UIButton *stopButton;
@property UIButton *refreshButton;
@property UIButton *twitterListButton;
@property UIButton *addButton;
@property int webCount;
@property TwitterViewController *twitterViewController;
@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createToolsView];
    [self createCollectionView];
    [self createButtons];
    [self createOmnibar];
    [self createProgressBar];
    [self createGestures];
    [self loadTabs];
    self.webCount = 0;
    self.twitterViewController = [[TwitterViewController alloc] init];      //moved from 1st line of showTwitterLinks for faster tweet fetching
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitterURL"];

    if (urlString)
    {
        [self addTab:urlString];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"twitterURL"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [self showTools];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.showingTools)
    {
        [self.omnibar becomeFirstResponder];
    }
}

#pragma mark - Setup Scene

- (void)createToolsView
{
    self.toolsView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                              self.view.frame.origin.y,
                                                              self.view.frame.size.width,
                                                              self.view.frame.size.height)];
    self.toolsView.backgroundColor = [UIColor whiteColor];
    self.toolsView.alpha = 0.85;
    self.showingTools = true;
    [self.view addSubview:self.toolsView];
}

- (void)createOmnibar
{
    self.omnibar = [[UITextField alloc] initWithFrame:CGRectMake(self.toolsView.frame.origin.x+20,          //20
                                                                 self.toolsView.frame.size.height/2-20,     //264
                                                                 self.toolsView.frame.size.width-(2*20),    //280
                                                                 2*20)];                                    //40
    self.omnnibarFrame = self.omnibar.frame;
    self.omnibar.delegate = self;
    self.omnibar.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.omnibar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.omnibar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.omnibar.keyboardType = UIKeyboardTypeEmailAddress;
    self.omnibar.returnKeyType = UIReturnKeyGo;
    self.omnibar.placeholder = @"search";
    self.omnibar.adjustsFontSizeToFitWidth = YES;
    self.omnibar.textAlignment = NSTextAlignmentCenter;
    self.omnibar.font = [UIFont systemFontOfSize:32];
    [self.toolsView addSubview:self.omnibar];
    [self.omnibar becomeFirstResponder];
}

- (void)createProgressBar
{
    self.progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                       self.view.frame.origin.y,
                                                                       320,
                                                                       2)];
    self.progressBar.progress = 0;
    self.progressBar.progressTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.progressBar.tintColor = [UIColor grayColor];
    self.progressBar.hidden = YES;
    [self.view addSubview:self.progressBar];
    [self.view bringSubviewToFront:self.progressBar];
}

- (void)createCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.tabsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 20, 320, 148)
                                                 collectionViewLayout:flowLayout];
    self.tabsCollectionView.dataSource = self;
    self.tabsCollectionView.delegate = self;
    self.tabsCollectionView.backgroundColor = [UIColor whiteColor];
    [self.tabsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.toolsView addSubview:self.tabsCollectionView];
}

- (void)showTwitterLinks
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.twitterViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Gestures

- (void)createGestures
{
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:self.tap];
    self.tap.delegate = self;

    self.swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)];
    self.swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:self.swipeUp];
    self.swipeUp.delegate = self;

    self.swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
    self.swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:self.swipeDown];
    self.swipeDown.delegate = self;

    self.swipeFromRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromRight:)];
    self.swipeFromRight.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:self.swipeFromRight];
    self.swipeFromRight.delegate = self;

    self.swipeFromLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromLeft:)];
    self.swipeFromLeft.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:self.swipeFromLeft];
    self.swipeFromLeft.delegate = self;

    self.edgeSwipeFromRight = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(handleEdgeSwipeFromRight:)];
    [self.edgeSwipeFromRight setEdges:UIRectEdgeRight];
    [self.edgeSwipeFromRight setDelegate:self];
    [self.view addGestureRecognizer:self.edgeSwipeFromRight];
    
    self.edgeswipeFromLeft = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(handleEdgeSwipeFromLeft:)];
    [self.edgeswipeFromLeft setEdges:UIRectEdgeLeft];
    [self.edgeswipeFromLeft setDelegate:self];
    [self.view addGestureRecognizer:self.edgeswipeFromLeft];
}

- (void)handleTapFrom:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
//        CGPoint point = [sender locationInView:self.toolsView];
//        [self switchToTab:[self.tabsCollectionView indexPathForItemAtPoint:point].item];

//        for (UICollectionViewCell *cell in self.view.subviews)
//        {
//            NSLog(@"%@",cell.frame);
//
//            if (CGRectContainsPoint(cell.frame, point))
//            {
//                NSIndexPath *path = [self.tabsCollectionView indexPathForCell:cell];
//                [self switchToTab:path.item];
//            }
//        }
    }
}

- (void)handleSwipeUp:(UISwipeGestureRecognizer *)sender
{
    Tab *tab = self.tabs[self.currentTabIndex];

    if (self.showingTools && tab.currentImageIndex > 0)
    {
        [self share];
    }
}

- (void)handleSwipeDown:(UISwipeGestureRecognizer *)sender
{
    if (self.showingTools)
    {
        [self.omnibar resignFirstResponder];
    }
}

- (void)handleSwipeFromRight:(UISwipeGestureRecognizer *)sender
{
    Tab *tab = self.tabs[self.currentTabIndex];
    int indexOfToolsView = (int) [self.view.subviews indexOfObject:self.toolsView];
    int indexOfWebView = (int) [self.view.subviews indexOfObject:tab.webView];

    if (indexOfToolsView < indexOfWebView)
    {
        [self showTools];
    }
}

- (void)handleSwipeFromLeft:(UISwipeGestureRecognizer *)sender
{
    Tab *tab = self.tabs[self.currentTabIndex];
    int indexOfToolsView = (int) [self.view.subviews indexOfObject:self.toolsView];
    int indexOfWebView = (int) [self.view.subviews indexOfObject:tab.webView];

    if (indexOfToolsView > indexOfWebView)
    {
        [self showWeb];
    }
}

- (void)handleEdgeSwipeFromRight:(UIScreenEdgePanGestureRecognizer *)sender
{
    Tab *tab = self.tabs[self.currentTabIndex];
    CGPoint point = [sender locationInView:self.view];

    if (!self.showingTools && [tab.webView canGoForward])
    {
        if (sender.state == UIGestureRecognizerStateBegan)
        {
            NSLog(@"going forward, current img index is: %i",tab.currentImageIndex);
            tab.screenshots[tab.currentImageIndex] = [tab.webView snapshotViewAfterScreenUpdates:NO];
            self.currentScreenshot = tab.screenshots[tab.currentImageIndex];
            self.futureScreenshot = tab.screenshots[tab.currentImageIndex+1];
            self.view.userInteractionEnabled = NO;
        }

        [self.view addSubview:self.currentScreenshot];
        [self.view insertSubview:self.futureScreenshot aboveSubview:self.currentScreenshot];
        self.futureScreenshot.transform = CGAffineTransformMakeTranslation(point.x, self.view.frame.origin.y);

        if (sender.state == UIGestureRecognizerStateEnded)
        {
            if (point.x < self.view.frame.size.width/2)
            {
                [tab.webView goForward];
                [UIView animateWithDuration:.1 animations:^{
                    self.futureScreenshot.transform = CGAffineTransformMakeTranslation(self.view.frame.origin.x, self.view.frame.origin.y);
                }];

                //wait for tab.webview to finish loading to prevent flashing
                self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:.5
                                                                  target:self
                                                                selector:@selector(finishGoingForward)
                                                                userInfo:nil
                                                                 repeats:NO];
            }
            else
            {
                [UIView animateWithDuration:.1 animations:^{
                    self.futureScreenshot.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, self.view.frame.origin.y);
                }];
                [self.currentScreenshot removeFromSuperview];
                [self.futureScreenshot removeFromSuperview];
                self.currentScreenshot = nil;
                self.futureScreenshot = nil;
            }
            self.view.userInteractionEnabled = YES;
        }
    }
}

- (void)finishGoingForward
{
    Tab *tab = self.tabs[self.currentTabIndex];
    [self.view insertSubview:tab.webView belowSubview:self.futureScreenshot];
    tab.currentImageIndex++;
    [self.currentScreenshot removeFromSuperview];
    [self.futureScreenshot removeFromSuperview];
    self.currentScreenshot = nil;
    self.futureScreenshot = nil;

}

- (void)handleEdgeSwipeFromLeft:(UIScreenEdgePanGestureRecognizer *)sender
{
    Tab *tab = self.tabs[self.currentTabIndex];
    CGPoint point = [sender locationInView:self.view];

    if (!self.showingTools && [tab.webView canGoBack])
    {
        if (sender.state == UIGestureRecognizerStateBegan)
        {
            NSLog(@"going back, current img index is: %i",tab.currentImageIndex);
            tab.screenshots[tab.currentImageIndex] = [tab.webView snapshotViewAfterScreenUpdates:NO];
            self.currentScreenshot = tab.screenshots[tab.currentImageIndex];
            self.pastScreenshot = tab.screenshots[tab.currentImageIndex-1];
            self.view.userInteractionEnabled = NO;
        }

        [self.view addSubview:self.currentScreenshot];
        [self.view insertSubview:self.pastScreenshot belowSubview:self.currentScreenshot];
        self.currentScreenshot.transform = CGAffineTransformMakeTranslation(point.x, self.view.frame.origin.y);

        if (sender.state == UIGestureRecognizerStateEnded)
        {
            if (point.x > self.view.frame.size.width/2)
            {
                [tab.webView goBack];
                [UIView animateWithDuration:.1 animations:^{
                    self.currentScreenshot.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, self.view.frame.origin.y);
                }];

                //wait for tab.webview to finish loading to prevent flashing
                self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:.5
                                                                  target:self
                                                                 selector:@selector(finishGoingBack)
                                                                userInfo:nil
                                                                 repeats:NO];
            }
            else
            {
                [UIView animateWithDuration:.1 animations:^{
                    self.currentScreenshot.transform = CGAffineTransformMakeTranslation(self.view.frame.origin.x,  self.view.frame.origin.y);
                }];
                [self.currentScreenshot removeFromSuperview];
                [self.pastScreenshot removeFromSuperview];
                self.currentScreenshot = nil;
                self.pastScreenshot = nil;
            }
            self.view.userInteractionEnabled = YES;
        }
    }
}

- (void)finishGoingBack
{
    Tab *tab = self.tabs[self.currentTabIndex];
    [self.view insertSubview:tab.webView belowSubview:self.currentScreenshot];
    tab.currentImageIndex--;
    [self.currentScreenshot removeFromSuperview];
    [self.pastScreenshot removeFromSuperview];
    self.currentScreenshot = nil;
    self.pastScreenshot = nil;
}

#pragma mark - Tabs

- (void)loadTabs
{
    self.tabs = [[NSMutableArray alloc] init];

    NSArray *savedUrlStrings = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedUrlStrings"];
    if (savedUrlStrings)
    {
        for (NSString *urlString in savedUrlStrings)
        {
            [self addTab:urlString];
        }
    }
    else
    {
        [self addTab:nil];
    }
}

- (void)saveTabs
{
    NSMutableArray *tempArrayOfUrlStrings = [[NSMutableArray alloc] init];

    for (Tab *tab in self.tabs)
    {
        [tempArrayOfUrlStrings addObject:tab.webView.request.URL.absoluteString];
    }

    [[NSUserDefaults standardUserDefaults] setObject:tempArrayOfUrlStrings forKey:@"savedUrlStrings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addTab:(NSString *)urlString
{
    if (self.tabs.count != 0)
    {
        Tab *oldTab = self.tabs[self.currentTabIndex];
        [oldTab.webView removeFromSuperview];
    }

    Tab *newTab = [[Tab alloc] init];
    [self.tabs addObject:newTab];
    [self.view insertSubview:newTab.webView belowSubview:self.toolsView];
    newTab.webView.userInteractionEnabled = NO; //fixes bug when doubletapping on blank tab.webview
    newTab.webView.delegate = self;
    newTab.webView.scalesPageToFit = YES;
    self.currentTabIndex = (int) self.tabs.count-1;
    self.refreshButton.enabled = NO;

    if([urlString isKindOfClass:[NSString class]])
    {
        newTab.urlString = [self searchOrLoad:urlString];
        [self loadPage:newTab];
    }

    [self.tabsCollectionView reloadData];
}

- (void)switchToTab:(int)newTabIndex
{
    NSLog(@"Switching to Tab: %i", newTabIndex);

    if (newTabIndex != self.currentTabIndex)
    {
        Tab *oldTab = self.tabs[self.currentTabIndex];
        [oldTab.webView removeFromSuperview];
    }

    Tab *newTab = self.tabs[newTabIndex];
    [self.view insertSubview:newTab.webView belowSubview:self.toolsView];
    self.currentTabIndex = newTabIndex;
//    newTab.webView.delegate = self; //redundant? Already set in addTab
//    newTab.webView.scalesPageToFit = YES; //redundant?
}

- (void)removeTab:(Tab *)tab
{
    [tab.webView removeFromSuperview];
    [self.tabs removeObject:tab];
    [self.tabsCollectionView reloadData];
    [self switchToTab:0];
}

#pragma mark - UICollectionView DataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tabs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    if(!cell)
    {
        cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                      self.view.frame.origin.y,
                                                                      80,
                                                                      148)];
    }

    Tab *tab = self.tabs[self.currentTabIndex];
    UIView *view = tab.screenshots[tab.currentImageIndex];
    cell.backgroundView = view;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(80, 148);
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.omnibar resignFirstResponder];
    Tab *tab = self.tabs[self.currentTabIndex];
    tab.urlString = [self searchOrLoad:textField.text];
    self.omnibar.text = @"";
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
    NSArray *urlEndings = @[@".com",@".co",@".net",@".io",@".org",@".edu",@".to",@".ly"];

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
//    NSString *noSpaces = [userInput stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *noSpaces = [self urlEncode:userInput];
    NSString *searchUrl = [NSString stringWithFormat:@"https://www.google.com/search?q=%@&cad=h", noSpaces];
    return searchUrl;
}

- (NSString *)urlEncode:(NSString *)unencodedString
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)unencodedString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 ));
    return encodedString;
}

#pragma mark - Loading Web Page & Hiding/Shwoing Views

- (void)loadPage:(Tab *)tab
{
    [tab.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tab.urlString]]];
    [self showWeb];
}

- (void)showWeb
{
    self.showingTools = false;

    [self.omnibar resignFirstResponder];

    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];


    Tab *tab = self.tabs[self.currentTabIndex];
    tab.webView.frame = CGRectMake(self.view.frame.origin.x,
                                   self.view.frame.origin.y,
                                   self.view.frame.size.width,
                                   self.view.frame.size.height);

    [self.view insertSubview:tab.webView aboveSubview:self.toolsView];
}

- (void)showTools
{
    self.showingTools = true;

    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    Tab *tab = self.tabs[self.currentTabIndex];
    [self.view insertSubview:tab.webView belowSubview:self.toolsView];
    [self.omnibar becomeFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake)
    {
        [self showTools]; //or can use [self cancelRefreshSwitch];
    }
}


#pragma mark - UIWebView Delegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.webCount++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.progressBar.hidden = NO;
    self.progressBar.progress = 0;
    self.doneLoading = false;

    Tab *tab = self.tabs[self.currentTabIndex];
    tab.webView.userInteractionEnabled = YES; //fixes bug when doubletapping on blank tab.webview

    self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:0.025
                                                      target:self
                                                    selector:@selector(timerCallback)
                                                    userInfo:nil
                                                     repeats:YES];
    [self enableShare:YES Refresh:NO Stop:YES];
}

-(void)timerCallback
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
    self.webCount--;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self animateProgressBarHide];
    [self takeScreenshot];
    [self enableShare:YES Refresh:YES Stop:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.webCount--;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self animateProgressBarHide];
    [self enableShare:YES Refresh:YES Stop:NO];
}

- (void)takeScreenshot
{
    Tab *tab = self.tabs[self.currentTabIndex];
    if (self.webCount==0) //&& [[tab.webView stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqual:@"complete"])
    {
        if ([tab.webView.request.URL.absoluteString isEqualToString:tab.urls[tab.currentImageIndex]])
        {
            NSLog(@"same so replacing");
            tab.screenshots[tab.currentImageIndex] = [tab.webView snapshotViewAfterScreenUpdates:YES];
        }
        else
        {
            NSLog(@"not same, new index: %i",tab.currentImageIndex+1);
            tab.currentImageIndex++;
            [tab.urls insertObject:tab.webView.request.URL.absoluteString atIndex:tab.currentImageIndex];
            [tab.screenshots insertObject:[tab.webView snapshotViewAfterScreenUpdates:YES] atIndex:tab.currentImageIndex];

            NSLog(@"index: %i url: %@",tab.currentImageIndex,tab.urls[tab.currentImageIndex]);
        }
    }
}

#pragma mark - Low Memory Alert

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Landscape Layout Adjust

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.omnibar.frame = self.omnnibarFrame;

        self.toolsView.frame = CGRectMake(self.view.frame.origin.x,
                                          self.view.frame.origin.y,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height);
    }
    else
    {
        self.omnibar.frame = CGRectMake((self.view.frame.size.height-self.omnibar.frame.size.width)/2,
                                        self.view.frame.origin.y+100,
                                        self.omnibar.frame.size.width,
                                        self.omnibar.frame.size.height);

        self.toolsView.frame = CGRectMake(self.view.frame.origin.x,
                                          self.view.frame.origin.y,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height);
    }
}

#pragma mark - Buttons

- (void)createButtons
{
//    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [self.shareButton addTarget:self
//                         action:@selector(share)
//               forControlEvents:UIControlEventTouchUpInside];
//    [self.shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
//    self.shareButton.frame = CGRectMake(20, 20, 32, 32);
//    self.shareButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
//    [self.toolsView addSubview:self.shareButton];

    self.refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.refreshButton addTarget:self
                           action:@selector(refreshPage)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.refreshButton setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    self.refreshButton.frame = CGRectMake(77, 17, 38, 38);
    self.refreshButton.center = CGPointMake(self.view.frame.size.width/2+50, self.view.frame.size.height/2-50);
    [self.toolsView addSubview:self.refreshButton];

    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton addTarget:self
                        action:@selector(cancelPage)
              forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    self.stopButton.frame = CGRectMake(80, 20, 32, 32);
    self.stopButton.center = CGPointMake(self.view.frame.size.width/2+50, self.view.frame.size.height/2-50);
    [self.toolsView addSubview:self.stopButton];

    self.twitterListButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.twitterListButton addTarget:self
                               action:@selector(showTwitterLinks)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.twitterListButton setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
    self.twitterListButton.frame = CGRectMake(20, 20, 32, 32);
    self.twitterListButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-50);
    [self.toolsView addSubview:self.twitterListButton];

    self.addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addButton addTarget:self
                       action:@selector(addTab:)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.addButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    self.addButton.frame = CGRectMake(20, 20, 32, 32);
    self.addButton.center = CGPointMake(self.view.frame.size.width/2-50, self.view.frame.size.height/2-50);
    [self.toolsView addSubview:self.addButton];

    [self enableShare:NO Refresh:NO Stop:NO];
    self.refreshButton.hidden = NO;
    self.refreshButton.enabled = NO;
}

- (void)enableShare:(BOOL)B1 Refresh:(BOOL)B2 Stop:(BOOL)B3
{
    self.shareButton.enabled = B1;
    self.shareButton.hidden = !B1;
    self.refreshButton.enabled = B2;
    self.refreshButton.hidden = !B2;
    self.stopButton.enabled = B3;
    self.stopButton.hidden = !B3;
}

- (void)refreshPage
{
    Tab *tab = self.tabs[self.currentTabIndex];
    [tab.webView reload];
}

- (void)cancelPage
{
    Tab *tab = self.tabs[self.currentTabIndex];
    [tab.webView stopLoading];
}

- (void)share
{
    Tab *tab = self.tabs[self.currentTabIndex];
    NSString *title = [tab.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *text = [@"Check out: " stringByAppendingString:title];
    NSURL *url = tab.webView.request.URL;

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[text, url]
                                                                             applicationActivities:nil];

    controller.excludedActivityTypes = @[UIActivityTypeAddToReadingList,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo];

    [self presentViewController:controller animated:YES completion:nil];
}

@end