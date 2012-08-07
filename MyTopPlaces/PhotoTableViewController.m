//
//  PhotoTableViewController.m
//  MyTopPlaces
//
//  Created by Tatiana Kornilova on 8/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoTableViewController.h"

@implementation PhotoTableViewController

@synthesize photos = _photos;
@synthesize place = _place;
@synthesize cellId = _cellId;

-(void)setPhotos:(NSMutableArray *)photos
{
    if (_photos!=photos) {
        _photos=photos;
        if (self.tableView.window) [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self retrievePhotoList];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSMutableArray *)retrievePhotoList
{
    // set self.photos
    self.photos = nil;
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
//    [self retrievePhotoList];
        
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
       
    UITableViewCell *cell = 
    [tableView dequeueReusableCellWithIdentifier:self.cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                      reuseIdentifier:self.cellId];
    }
    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    NSString *photoTitle = [photo objectForKey:FLICKR_PHOTO_TITLE];
    NSString *photoDescription = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    if ([photoTitle length]==0 && [photoDescription length]!=0) {
        photoTitle = photoDescription;
        photoDescription = nil;
    }
    if ([photoTitle length]==0 && [photoDescription length]==0) {
        photoTitle = @"Unknown";
    }
    cell.textLabel.text = photoTitle;
    cell.detailTextLabel.text = photoDescription;
    
    dispatch_queue_t q = dispatch_queue_create("thumbnail download queue", 0);
    
    dispatch_async(q, ^{
        NSURL *thumbnailURL = 
        [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare];
        
        UIImage *thumbnail = [UIImage imageWithData:
                              [NSData dataWithContentsOfURL:thumbnailURL]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = thumbnail;
            
            [cell setNeedsLayout];
        });
                            
    });
    
    dispatch_release(q);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] != 
        UIUserInterfaceIdiomPad)
        return;
    
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    NSDictionary *photo = [self.photos objectAtIndex:path.row];
	// Get a handle to the detail view controller
    
    TopPlacesPhotoViewController *photoViewController = 
    (TopPlacesPhotoViewController *) [[self.splitViewController viewControllers] lastObject];
    
	if (photoViewController) {
		// Set up the photoViewController model and synchronize it's views
		[photoViewController setPhoto:photo];
        [[photoViewController navigationItem] setTitle: self.title];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        
        [photoViewController setPhotoTitle : cell.textLabel.text];
	} // otherwise handled by the segue
    
}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (![segue.destinationViewController
         isKindOfClass:[TopPlacesPhotoViewController class]])
        return;
            
//    NSAssert([sender isKindOfClass:[UITableViewCell class]],
//             @"ERROR: Unexpected class");
    
//    [(TopPlacesPhotoViewController *)segue.destinationViewController setPhoto:photo];
    
//    [[(TopPlacesPhotoViewController *)segue.destinationViewController navigationItem]
//     setTitle:[[sender textLabel] text]];
    //    [segue.destinationViewController setTitle:[[sender textLabel] text]];
    //    [RecentsUserDefaults saveRecentsUserDefaults:photo];
    
    
}

@end
