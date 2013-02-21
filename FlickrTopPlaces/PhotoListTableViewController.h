//
//  PhotoListTableViewController.h
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-14.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoListMapViewController.h"

@interface PhotoListTableViewController : UITableViewController <MapViewControllerDelegate>
@property (nonatomic, strong) NSDictionary *place;
@property (nonatomic, strong) NSArray *photoList;

// Public since subclass is using these methods
- (NSArray *)mapAnnotations;
- (void)updateSplitViewDetail;
- (void)updateSplitViewDetailWithPhoto:(NSDictionary *)photo;

@end
