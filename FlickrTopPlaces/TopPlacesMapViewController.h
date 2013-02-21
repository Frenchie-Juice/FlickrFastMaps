//
//  TopPlacesMapViewController.h
//  FlickrMaps
//
//  Created by Fred Gagnepain on 2013-02-15.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class TopPlacesMapViewController;

@protocol TopPlacesMapViewControllerDelegate <NSObject>
- (void) mapViewController:(TopPlacesMapViewController *)sender displayPhotoListForAnnotation:(id <MKAnnotation>)annotation;
@end

@interface TopPlacesMapViewController : UIViewController
@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>
@property (nonatomic, weak) id <TopPlacesMapViewControllerDelegate> delegate;

@end
