//
//  FlickrPhotoCache.h
//  MyTopPlaces5
//
//  Created by Tatiana Kornilova on 8/6/12.
//
//

#import <Foundation/Foundation.h>

@interface FlickrPhotoCache : NSObject
-(void)retrievePhotoCache;

-(BOOL)isInCache:(NSDictionary *)photo;

-(NSString *)readImageFromCache:(NSDictionary *)photo;

-(void)writeImageToCache:(UIImage *)image forPhoto:(NSDictionary *)photo fromUrl:(NSURL *)url;

@end
