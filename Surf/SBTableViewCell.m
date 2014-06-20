//
//  SBTableViewCell.m
//  Surf
//
//  Created by Sapan Bhuta on 6/9/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "SBTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SDWebImage/UIImageView+WebCache.h"

@implementation SBTableViewCell

- (void)modifyCellLayoutWithData:(NSDictionary *)layoutData
{
    self.textLabel.text = layoutData[@"textLabel"];
    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.font = [UIFont systemFontOfSize:14];

    self.detailTextLabel.text = layoutData[@"detailTextLabel"];
    self.detailTextLabel.numberOfLines = (int)layoutData[@"numberOfLines"];
    self.detailTextLabel.textColor = [UIColor grayColor];

    [self.imageView setImageWithURL:[NSURL URLWithString:layoutData[@"imgUrlString"]]
                   placeholderImage:[UIImage imageNamed:@"bluewave"]];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 48/2;

}

@end
