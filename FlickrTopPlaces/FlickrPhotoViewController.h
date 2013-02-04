//
//  FlickrPhotoViewController.h
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-14.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrPhotoViewController : UIViewController
@property (strong, nonatomic) NSDictionary *photo;

- (void)refreshDisplay;
@end
