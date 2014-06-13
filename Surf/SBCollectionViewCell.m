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
    NSLog(@"pan translation: %f,%f",translation.x,translation.y);
    NSLog(@"pan velocity: %f,%f",velocity.x,velocity.y);

    if (translation.y < 0)
    {
        self.transform = CGAffineTransformMakeTranslation(0, translation.y);
    }

    if (translation.y < -100 || velocity.y < -1000)
    {
        NSLog(@"removing");
        self.transform = CGAffineTransformMakeTranslation(0, -150);     //slowdown
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveTab" object:self];
        return;
    }

    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
    {
        self.transform = CGAffineTransformMakeTranslation(0, self.originalCenter.y-self.center.y);
    }
}

@end
