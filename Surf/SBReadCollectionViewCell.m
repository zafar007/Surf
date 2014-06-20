//
//  SBTableViewCell.m
//  Surf
//
//  Created by Sapan Bhuta on 6/9/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "SBReadCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SDWebImage/UIImageView+WebCache.h"

@implementation SBReadCollectionViewCell

- (void)modifyCellLayoutWithData:(NSDictionary *)layoutData
{
    self.backgroundColor = [UIColor whiteColor];

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10+48+10, 0, 320-68, self.contentView.frame.size.height)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,48,48)];
    imageView.center = CGPointMake(10+24,
                                   CGRectGetMidY(self.contentView.frame));

    NSString *imgURL = layoutData[@"imgUrlString"];
    NSString *title = layoutData[@"textLabel"];
    NSString *subtitle = layoutData[@"detailTextLabel"];

    textView.text = [NSString stringWithFormat:@"%@\n\n%@",title,subtitle];
    textView.font = [UIFont systemFontOfSize:14];
    textView.editable = NO;
    textView.selectable = NO;

    [imageView setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[UIImage imageNamed:@"bluewave"]];
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 48/2;

    [self.contentView addSubview:textView];
    [self.contentView addSubview:imageView];

    //    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //    self.textLabel.font = [UIFont systemFontOfSize:14];
    //    self.detailTextLabel.textColor = [UIColor grayColor];

}

@end
