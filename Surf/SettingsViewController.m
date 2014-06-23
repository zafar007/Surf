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
@property NSMutableArray *someButtons;
@property UIBarButtonItem *editButton;
@property UIBarButtonItem *cancelButton;
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.fullButtons = [[NSUserDefaults standardUserDefaults] objectForKey:@"buttonsFull"];
    self.someButtons = [[[NSUserDefaults standardUserDefaults] objectForKey:@"buttonsSome"] mutableCopy];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                   self.view.frame.origin.y,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height)
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self
                                                                                action:@selector(edit)];

    self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                  target:self
                                                                                  action:@selector(unwind)];
    self.navigationItem.leftBarButtonItem = self.editButton;
    self.navigationItem.rightBarButtonItem = self.cancelButton;
}


- (void)unwind
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:self.someButtons] forKey:@"buttonsSome"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Table Editing


- (void)edit
{
    if ([self.tableView isEditing])
    {
        [self.tableView setEditing:NO animated:YES];
        self.editButton.style = UIBarButtonSystemItemEdit;
    }
    else
    {
        [self.tableView setEditing:YES animated:YES];
        self.editButton.style = UIBarButtonSystemItemDone;
    }
}

/*
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES; //change to YES to get delete swipe on cell
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.savedPosts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self setData];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    UITableViewCell *cell = [self.savedPosts objectAtIndex:fromIndexPath.row];
    [self.savedPosts removeObjectAtIndex:fromIndexPath.row];
    [self.savedPosts insertObject:cell atIndex:toIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
*/

#pragma mark - UITableView DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fullButtons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = self.fullButtons[indexPath.item];

    for (UIView *view in cell.subviews)
    {
        [view isKindOfClass:[SBSwitch class]] ? [view removeFromSuperview] : nil;
    }

    SBSwitch *switchAtRow = [[SBSwitch alloc] init];
    switchAtRow.index = (int)indexPath.item;
    switchAtRow.center = CGPointMake(cell.frame.size.width-switchAtRow.frame.size.width, cell.center.y);
    [switchAtRow addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:switchAtRow];
    switchAtRow.on = ([self.someButtons containsObject:self.fullButtons[indexPath.row]]);

    return cell;
}

- (void)toggle:(SBSwitch *)sender
{
    if (sender.on)
    {
        [self.someButtons insertObject:self.fullButtons[sender.index] atIndex:sender.index]; // wrong
    }
    else
    {
        [self.someButtons removeObject:self.fullButtons[sender.index]];
    }
    [self.tableView reloadData];
}

@end
