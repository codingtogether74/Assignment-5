//
//  TopPlacesPhotoViewController.m
//   MyTopPlaces
//
//  Created by Tatiana Kornilova on 7/28/12.
//

#import "TopPlacesPhotoViewController.h"
#import "FlickrFetcher.h"
#import "RecentsUserDefaults.h"
#import "FlickrPhotoCache.h"

#define PHOTO_TITLE_KEY  @"title"
#define PHOTO_ID_KEY @"id"
#define TOO_MANY_PHOTOS 20

@interface TopPlacesPhotoViewController() <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) NSString *photoTitle;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation TopPlacesPhotoViewController
 
@synthesize photoScrollView = _photoScrollView;
@synthesize photoImageView = _photoImageView;
@synthesize toolbar = _toolbar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize photoTitle = _photoTitle;
@synthesize spinner = _spinner;

@synthesize photo = _photo;

- (void)synchronizeViewWithImage:(UIImage *) image
{
	self.photoImageView.image = image ;       //  [UIImage imageWithData:imageData];
	self.title = [self.photo objectForKey:PHOTO_TITLE_KEY];
	
	// Reset the zoom scale back to 1
	self.photoScrollView.zoomScale = 1;
    
    self.photoScrollView.maximumZoomScale = 10.0;
    self.photoScrollView.minimumZoomScale = 0.1;
    
	self.photoScrollView.contentSize = self.photoImageView.image.size;
	self.photoImageView.frame =
	CGRectMake(0, 0, self.photoImageView.image.size.width, self.photoImageView.image.size.height);
	
}
#pragma mark - Scroll View Delegate

// set the image that needs to be scrolled by the scrollview
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoImageView;
}

- (void)setPhotoTitle:(NSString *)photoTitle
{
    if ([photoTitle isEqualToString:@""])
        _photoTitle = @"no photo description";
    else
        _photoTitle = photoTitle;
    if (self.toolbar) {
    // title for the iPad
            NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
            UIBarButtonItem *titleButton = [toolbarItems objectAtIndex:[toolbarItems count]-2];
            titleButton.title = _photoTitle;
    } else {
    // title for the iPhone
            self.title = _photoTitle;
    }
}
   
- (void)fillView
{
    CGFloat hScale = self.photoScrollView.bounds.size.height/self.photoImageView.bounds.size.height;
    CGFloat wScale = self.photoScrollView.bounds.size.width/self.photoImageView.bounds.size.width;
    [self.photoScrollView setZoomScale:MAX(wScale, hScale) animated:YES];
    [self.photoImageView setNeedsDisplay];
}

- (void)loadPhoto
{
    if (self.photo) {
        [self.spinner startAnimating];
        dispatch_queue_t dispatchQueue = dispatch_queue_create("q_photo", NULL);
        
        // Load the image using the queue
        dispatch_async(dispatchQueue, ^{ 

//        NSURL *photoURL = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
//        NSData *photoData = [[NSData alloc] initWithContentsOfURL:photoURL];
//-------------- check cache ----------------------------------------------------------------------------
        NSURL *photoUrl;
        NSString *urlString;
        NSData *photoData;
            
       FlickrPhotoCache *flickrPhotoCache = [[FlickrPhotoCache alloc]init];
        [flickrPhotoCache retrievePhotoCache];
            
        if ([flickrPhotoCache isInCache:self.photo])
        {
                urlString = [flickrPhotoCache readImageFromCache:self.photo];//photo is in cache
                photoData = [NSData dataWithContentsOfFile:urlString];
                NSLog(@"load image from cache: %@",urlString);
        }
        else
        {
                photoUrl = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge]; //photo is not in cache
                NSLog(@"downloaded from url: %@",photoUrl);
                photoData = [NSData dataWithContentsOfURL:photoUrl];
        }
            UIImage *image = [UIImage imageWithData:photoData];
            //NSLog(@"image id to cache is %@",[self.photo objectForKey:FLICKR_PHOTO_ID]);
            [flickrPhotoCache writeImageToCache:image forPhoto:self.photo fromUrl:photoUrl]; //update photo cache
//------------------------------------------------------------------------------------------
            // Use the main queue to store the photo in NSUserDefaults and to display
            dispatch_async(dispatch_get_main_queue(), ^{

        if (photoData) {
            NSString *photoID = [self.photo objectForKey:PHOTO_ID_KEY];
			// Only store and display if another photo hasn't been selected
			if ([photoID isEqualToString:[self.photo objectForKey:PHOTO_ID_KEY]]) {
                [RecentsUserDefaults saveRecentsUserDefaults:self.photo];
				[self synchronizeViewWithImage:image];
				[self fillView]; // Sets the zoom level to fill screen
				[self.spinner stopAnimating];
			}
            // Assignment 4 - task 7
            self.photoTitle = [self.photo valueForKey:FLICKR_PHOTO_TITLE];
        } else {
            self.photoTitle = @"no photo retrieved";
        }
            });
                
        });
        dispatch_release(dispatchQueue);
    } else {
        self.photoTitle = @"no photo selected";

    }
}

//  This one was added for the iPad splitview
//  It needs displaying the image again if the photo is changed
- (void)setPhoto:(NSDictionary *)photo {
    if (photo != _photo) {
        _photo = photo;
        // Model chaned, so update our View (the table)
      if (self.photoImageView.window)  [self loadPhoto];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.photoScrollView.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
	if (self.photo) [self loadPhoto];
	
}

- (void)viewWillLayoutSubviews {
    
	// Zoom the image to fill up the view
	if (self.photoImageView.image) [self fillView];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (YES);
}

- (void)viewDidUnload {
    [self setPhotoImageView:nil];
    [self setPhotoScrollView:nil];
    [self setToolbar:nil];
    [self setPhotoScrollView:nil];
    [self setSpinner:nil];
    [super viewDidUnload];
}

#pragma mark - Split View Controller

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem {
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) {
            [toolbarItems removeObject:_splitViewBarButtonItem];
        }
        if (splitViewBarButtonItem) {
            [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        }
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

@end
