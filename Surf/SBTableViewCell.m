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

    [self.imageView setImageWithURL:[NSURL URLWithString:layoutData[@"urlString"]]
                   placeholderImage:[UIImage imageNamed:@"bluewave"]];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 48/2;

}

+ (CGFloat)heightForCellWithTweet:(NSDictionary *)tweet
{
    //figure out height using data from Tweet

    CGFloat padding = 10;
    CGFloat sizeOfTweetText = [tweet[@"text"] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}].height;
    CGFloat sizeOfTweetUserName = [tweet[@"user"][@"name"] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}].height;
    CGFloat sizeOfRetweetUserName = 0;

    if (tweet[@"retweeted_status"])
    {
        sizeOfTweetText = [tweet[@"text"] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}].height;;
        NSString *retweetUserName = [NSString stringWithFormat:@"Retweeted by: %@", tweet[@"retweeted_status"][@"user"][@"name"]];
        sizeOfRetweetUserName = [retweetUserName sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}].height;
    }

    CGFloat totalTextSize = sizeOfTweetText + sizeOfTweetUserName + sizeOfRetweetUserName + padding*2;

    NSLog(@"total: %f", totalTextSize);

    if (totalTextSize*2 < 68)
    {
        return 68;
    }
    else
    {
        return totalTextSize*2;
    }
}

@end
