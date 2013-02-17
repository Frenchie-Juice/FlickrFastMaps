//
//  MapViewController.h
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-30.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@class PhotoListMapViewController;

@protocol MapViewControllerDelegate <NSObject>
- (NSData *) mapViewController:(PhotoListMapViewController *)sender imageDataForAnnotation:(id <MKAnnotation>)annotation;
- (MKCoordinateRegion) computeMapRegion:(NSArray *)annotations sender:(id)sender;
- (void) mapViewController:(PhotoListMapViewController *)sender displayPhotoForAnnotation:(id <MKAnnotation>)annotation;
@end

@interface PhotoListMapViewController : UIViewController 
@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;
@property (nonatomic) BOOL zoomToRegion;

@end
