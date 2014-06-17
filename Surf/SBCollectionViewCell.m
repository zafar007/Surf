//
//  SBCollectionViewCell.m
//  Surf
//
//  Created by Sapan Bhuta on 6/11/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "SBCollectionViewCell.h"

@interface SBCollectionViewCell () <UIGestureRecognizerDelegate>
@property UIPanGestureRecognizer *pan;
@property CGPoint originalCenter;
@property CGRect originalFrame;
@end

@implementation SBCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.originalCenter = self.center;
        self.originalFrame = self.frame;
        self.backgroundColor = [UIColor lightGrayColor];
        self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
        self.pan.delegate = self;
        [self addGestureRecognizer:self.pan];
    }
    return self;
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:self];
    CGPoint velocity = [sender velocityInView:self];

    if (translation.y < 0)
    {
        self.transform = CGAffineTransformMakeTranslation(0, translation.y);
    }

    if (sender.state == UIGestureRecognizerStateEnded && (translation.y < -100 || velocity.y < -1000))
    {
        self.transform = CGAffineTransformMakeTranslation(0, -150);     //slowdown
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveTab" object:self];
    }
    else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
    {
        self.transform = CGAffineTransformMakeTranslation(0, self.originalCenter.y-self.center.y);
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        if ([gestureRecognizer translationInView:self].y < -1)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
}

@end