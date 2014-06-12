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
@end

@implementation SBCollectionViewCell

- (id)initWithFrame:(CGRect)frame Tab:(Tab *)tab
{
    self = [super initWithFrame:frame];
    if (self)
    {
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

    NSLog(@"pan w/\ntranslation: %f,%f\nvelocity: %f,%f",translation.x,translation.y,velocity.x,velocity.y);

    if (translation.y < -50 || velocity.y < -200)
    {
        NSLog(@"removing");
    }
}

@end
