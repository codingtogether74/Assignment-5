//
//  RecentsTableViewController.m
//  MyTopPlaces
//
//  Created by Tatiana Kornilova on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentsTableViewController.h"
#import "RecentsUserDefaults.h"

@implementation RecentsTableViewController

- (void)awakeFromNib
{
    self.cellId = @"Photos Description";
}

- (NSArray *)retrievePhotoList
{
     self.photos = [[RecentsUserDefaults retrieveRecentsUserDefaults] mutableCopy]; 
     return self.photos;
}


- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
     [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
	// Show the navigation bar for view controllers when this view disappears
//	[self.navigationController setNavigationBarHidden:NO animated:animated];
	[super viewWillDisappear:animated];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    NSDictionary *photo = [self.photos objectAtIndex:path.row];
    [segue.destinationViewController setPhoto:photo];
    [[segue.destinationViewController navigationItem] setTitle:[[sender textLabel] text]];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    
    [segue.destinationViewController setTitle : cell.textLabel.text];
}
@end
