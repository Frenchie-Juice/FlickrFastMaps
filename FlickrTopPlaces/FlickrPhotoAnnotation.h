//
//  FlickrPhotoAnnotation.h
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-30.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrPlaceAnnotation.h"

@interface FlickrPhotoAnnotation : NSObject <MKAnnotation>

+ (FlickrPhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo; // Flickr photo dictionary

@property (nonatomic, strong) NSDictionary *photo;

@end
