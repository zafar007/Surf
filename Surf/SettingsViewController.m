//
//  ReadSettingsViewController.m
//  Surf
//
//  Created by Sapan Bhuta on 6/15/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "SettingsViewController.h"
#import "SBSwitch.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>
@property UITableView *tableView;
@property NSArray *fullButtons;
@property NSMutableArray *buttons;
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.fullButtons = @[@"twitter",
                         @"global",
                         @"feedly",
                         @"pocket",
                         @"instapaper",
                         @"readability",
                         @"facebook",
                         @"pinterest",
                         @"dribbble",
                         @"bookmarks",
                         @"glasses",
                         @"hackernews",
                         @"reddit",
                         @"producthunt",
                         @"settings"];

    self.buttons = [NSMutableArray new];
    for (NSString *button in self.fullButtons)
    {
        [self.buttons addObject:button];
    }

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                   self.view.frame.origin.y,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height)
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                  target:self
                                                                                  action:@selector(unwind)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:cancelButton, nil];
}

- (void)unwind
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UITableView DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fullButtons.count-1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsCell"];
    }
    cell.textLabel.text = self.fullButtons[indexPath.item];

    SBSwitch *switchAtRow = [[SBSwitch alloc] init];
    switchAtRow.index = (int)indexPath.item;
    switchAtRow.center = CGPointMake(cell.frame.size.width-switchAtRow.frame.size.width, cell.center.y);
    [switchAtRow addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:switchAtRow];
    switchAtRow.on = ([self.buttons containsObject:self.fullButtons[indexPath.row]]);

    return cell;
}

- (void)toggle:(SBSwitch *)sender
{
    if (sender.on)
    {
        [self.buttons insertObject:self.fullButtons[sender.index] atIndex:sender.index];
    }
    else
    {
        [self.buttons removeObject:self.fullButtons[sender.index]];
    }
    [self.tableView reloadData];
    NSLog(@"%@",self.buttons);
}

@end
