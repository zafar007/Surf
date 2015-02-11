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

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 3.0;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 0.5/3;
        self.layer.masksToBounds = YES;

        self.originalCenter = self.center;
        self.originalFrame = self.frame;
        self.backgroundColor = [UIColor lightGrayColor];
        self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
        self.pan.delegate = self;
        [self addGestureRecognizer:self.pan];
    }
    return self;
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self];
    CGPoint velocity = [sender velocityInView:self];

    if (sender.state != UIGestureRecognizerStateEnded) {
        if (translation.y != 0) {
            self.transform = CGAffineTransformMakeTranslation(0, translation.y);
        }
    } else if (translation.y < -100 || velocity.y < -1000) {
        [UIView animateWithDuration:.3 animations:^{
            self.transform = CGAffineTransformMakeTranslation(0, -300);
        } completion:^(BOOL finished) {
            [self.vc removeTab:self];
        }];
    } else {
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:0 animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            //do nothing
        }];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ([gestureRecognizer translationInView:self].y != 0);
}

@end
