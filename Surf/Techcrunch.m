//
//  Techcrunch.m
//  Surf
//
//  Created by Sapan Bhuta on 7/19/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define kAPI @"http://techcrunch.com/feed/"

#import "Techcrunch.h"
#import "MWFeedParser.h"
#import "NSString+HTML.h"

@interface Techcrunch () <MWFeedParserDelegate>
@property MWFeedParser *feedParser;
@property NSMutableArray *parsedItems;
@property NSArray *itemsToDisplay;
@property NSDateFormatter *formatter;
@property NSMutableArray *posts;
@end

@implementation Techcrunch

- (void)getData
{
    NSLog(@"Techcrunch");

	self.formatter = [[NSDateFormatter alloc] init];
	[self.formatter setDateStyle:NSDateFormatterShortStyle];
	[self.formatter setTimeStyle:NSDateFormatterShortStyle];
	self.parsedItems = [[NSMutableArray alloc] init];
	self.itemsToDisplay = [NSArray array];

	NSURL *feedURL = [NSURL URLWithString:kAPI];
	self.feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
	self.feedParser.delegate = self;
	self.feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
	self.feedParser.connectionType = ConnectionTypeAsynchronously;
	[self.feedParser parse];
}

#pragma mark -
#pragma mark Parsing

- (void)refresh
{
	[self.parsedItems removeAllObjects];
	[self.feedParser stopParsing];
	[self.feedParser parse];
    //	self.tableView.userInteractionEnabled = NO;
    //	self.tableView.alpha = 0.3;
}

- (void)updateTableWithParsedItems
{
	self.itemsToDisplay = [self.parsedItems sortedArrayUsingDescriptors:
						   [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];

    self.posts = [NSMutableArray new];
    for (MWFeedItem *item in self.itemsToDisplay)
    {
        NSDictionary *post = @{@"link":item.link,
                               @"title":item.title,
                               @"author":item.author,
                               @"date":item.date};

        [self.posts addObject:post];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"Techcrunch" object:self.posts];
}

#pragma mark - MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser
{
    //	NSLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info
{
    //	NSLog(@"Parsed Feed Info: “%@”", info.title);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item
{
    //	NSLog(@"Parsed Feed Item: “%@”", item.title);
	if (item) [self.parsedItems addObject:item];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser
{
    //	NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    [self updateTableWithParsedItems];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error
{
	NSLog(@"Finished Parsing With Error: %@", error);
    if (self.parsedItems.count == 0)
    {
        //        self.title = @"Failed";
        // Show failed message in title
    }
    else
    {
        // Failed but some items parsed, so show and inform of error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parsing Incomplete"
                                                        message:@"There was an error during the parsing of this feed. Not all of the feed items could parsed."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
    [self updateTableWithParsedItems];
}

+ (NSDictionary *)layoutFrom:(NSDictionary *)post
{

    NSString *textLabel = post[@"title"];
    NSString *detailTextLabel = post[@"author"];
    //    NSString *detailTextLabel = [NSString stringWithFormat:@"%@ | %@", post[@"author"], post[@"date"]];

    return @{
             @"simple":@YES,
             @"text":textLabel,
             @"subtext":detailTextLabel,
             @"Cell1Exist":@YES,
             @"Cell1Image":@"pocket-cell",
             @"Cell1Color":[UIColor colorWithRed:0.941 green:0.243 blue:0.337 alpha:1],
             @"Cell1Mode":@2
             };
}

+ (NSString *)selected:(NSDictionary *)post
{
    return post[@"link"];
}

+ (CGFloat)width:(NSDictionary *)post
{
    return 320;
}

+ (CGFloat)height:(NSDictionary *)post
{
    //    NSString *text = post[@"title"];
    //    NSUInteger num = text.length;
    //    return MAX(num%44, 1)*10;
    return 68;
}

@end