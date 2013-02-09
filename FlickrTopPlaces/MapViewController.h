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

@class MapViewController;

@protocol MapViewControllerDelegate <NSObject>
- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation;
-(MKCoordinateRegion) computeMapRegion:(NSArray *)annotations sender:(id)sender;
@end

@interface MapViewController : UIViewController <SplitViewBarButtonItemPresenter>
@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;
@property (nonatomic) BOOL zoomToRegion;

@end
