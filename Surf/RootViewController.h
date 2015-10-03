//
//  RootViewController.h
//  Surf
//
//  Created by Sapan Bhuta on 5/30/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#define tabsOffset 30
#define showOffset 320
#define newTabAlpha .25
#define oldTabAlpha 1
#define tabProportion 4

#import "Tab.h"
#import "SBCollectionViewCell.h"
#import "PocketAPI.h"
#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"
#import "FBShimmering/FBShimmeringView.h"
#import <QuartzCore/QuartzCore.h>
@import Twitter;

@interface RootViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

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

- (void)removeTab:(UICollectionViewCell *)cell;
- (void)startLoadingUI;
- (void)endLoadingUI;
@end
