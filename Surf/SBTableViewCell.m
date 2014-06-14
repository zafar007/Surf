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

- (void)layoutWithTweetFrom:(NSMutableArray *)tweets AtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tweet = tweets[indexPath.row];
    NSDictionary *retweet = tweet[@"retweeted_status"];
    if (retweet)
    {
        tweet = retweet;
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@\nRetweeted by: %@",tweet[@"user"][@"name"], tweets[indexPath.row][@"user"][@"name"]];
        self.detailTextLabel.numberOfLines = 2;
        self.detailTextLabel.textColor = [UIColor grayColor];
    }
    else
    {
        self.detailTextLabel.text = tweet[@"user"][@"name"];
        self.detailTextLabel.textColor = [UIColor grayColor];
    }

    self.textLabel.text = [self modifyTweetText:tweet];
    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.font = [UIFont systemFontOfSize:14];

//    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:tweet[@"user"][@"profile_image_url"]]]];
    [self.imageView setImageWithURL:[NSURL URLWithString:tweet[@"user"][@"profile_image_url"]]
                   placeholderImage:[UIImage imageNamed:@"bluewave"]];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 48/2;
}

- (NSString *)modifyTweetText:(NSDictionary *)tweet
{
    NSString *tweetText = tweet[@"text"];
    NSURL *url = [NSURL URLWithString:tweet[@"entities"][@"urls"][0][@"expanded_url"]];
    NSArray *indices = tweet[@"entities"][@"urls"][0][@"indices"];
    int index0 = [indices[0] intValue];
    int index1 = [indices[1] intValue];
    NSString *host = url.host;
    NSString *newTweetText = [tweetText stringByReplacingCharactersInRange:NSMakeRange(index0, index1-index0) withString:host];

    return [self cleanup:newTweetText];
}

- (NSString *)cleanup:(NSString *)tweetText
{
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&apos;" withString:@"\'"];
    return tweetText;
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
