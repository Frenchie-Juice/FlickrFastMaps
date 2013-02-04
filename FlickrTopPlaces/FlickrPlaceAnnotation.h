//
//  FlickrDefaultAnnotation.h
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-30.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrPlaceAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSDictionary *place;

+ (FlickrPlaceAnnotation *)annotationForPlace:(NSDictionary *)place;
@end
