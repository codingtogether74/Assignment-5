//
//  TopPlacesPhotoViewController.h
//   MyTopPlaces
//
//  Created by Tatiana Kornilova on 7/28/12.
//  This class shows a single Flickr Photo in a scrollview

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"
#import "RotatableViewController.h"

//  this class implements the required SpltViewBarButtonItemPresenter methods

@interface TopPlacesPhotoViewController : RotatableViewController <SplitViewBarButtonItemPresenter>

@property (nonatomic, strong) NSDictionary *photo;
- (void)setPhotoTitle:(NSString *)photoTitle;
@end
