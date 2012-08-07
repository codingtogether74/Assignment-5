//
//  PhotosInPlacesTableViewController.m
//  MyTopPlaces
//
//  Created by Tatiana Kornilova on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosInPlacesTableViewController.h"
#import "RecentsUserDefaults.h"

@interface PhotosInPlacesTableViewController ()

@end

@implementation PhotosInPlacesTableViewController

- (void)awakeFromNib
{
    self.cellId = @"Photos Description";
}

#define MAX_RESULTS 50

- (NSMutableArray *)retrievePhotoList
{

   UIActivityIndicatorView *refreshSpinner =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
     UIActivityIndicatorViewStyleGray];
    
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithCustomView:refreshSpinner];
    [refreshSpinner startAnimating];
    dispatch_queue_t photoListFetchingQueue =
    dispatch_queue_create("photo list fetching queue", NULL);
    
    dispatch_async(photoListFetchingQueue, ^{
        if (self.photos)return;
        self.photos = [[FlickrFetcher photosInPlace:self.place
                                        maxResults:MAX_RESULTS] mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshSpinner stopAnimating];
            self.navigationItem.rightBarButtonItem =nil;
            [self.tableView reloadData];
        });
    });
    
    dispatch_release(photoListFetchingQueue);
   
    return nil;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    NSDictionary *photo = [self.photos objectAtIndex:path.row];
    [segue.destinationViewController setPhoto:photo];
    [[segue.destinationViewController navigationItem] setTitle:[[sender textLabel] text]];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    
    [segue.destinationViewController setPhotoTitle : cell.textLabel.text];
      [RecentsUserDefaults saveRecentsUserDefaults:photo];
}

@end
