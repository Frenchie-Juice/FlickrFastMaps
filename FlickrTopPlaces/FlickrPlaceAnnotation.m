//
//  FlickrDefaultAnnotation.m
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-30.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "FlickrPlaceAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrPlaceAnnotation

@synthesize place = _place;

+ (FlickrPlaceAnnotation *)annotationForPlace:(NSDictionary *)place
{
    FlickrPlaceAnnotation *annotation = [[FlickrPlaceAnnotation alloc] init];
    annotation.place = place;
    return annotation;
}

#pragma mark - MKAnnotation

- (NSString *)title
{
    return [FlickrFetcher parseCity:self.place];
}

- (NSString *)subtitle
{
    return [FlickrFetcher parseRegion:self.place];
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}


@end
