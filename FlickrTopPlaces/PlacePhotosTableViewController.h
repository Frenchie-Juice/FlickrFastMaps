//
//  PlacePhotosTableViewController.h
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-14.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlacePhotosTableViewController : UITableViewController
@property (nonatomic, strong) NSDictionary *place;
@property (nonatomic, strong) NSArray *placePhotos;
@end
