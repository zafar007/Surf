//
//  SBTableViewCell.m
//  Surf
//
//  Created by Sapan Bhuta on 6/9/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "SBReadCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation SBReadCollectionViewCell

- (void)modifyCellLayoutWith:(NSDictionary *)layoutViews
{
    for (UIView *view in self.contentView.subviews)
    {
        [view removeFromSuperview];
    }

    [self.contentView addSubview:layoutViews[@"contentView"]];
}

@end
