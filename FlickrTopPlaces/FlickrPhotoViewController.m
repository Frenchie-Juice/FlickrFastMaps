//
//  FlickrPhotoViewController.m
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-14.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "FlickrPhotoViewController.h"
#import "FlickrAPIKey.h"
#import "FlickrFetcher.h"

@interface FlickrPhotoViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation FlickrPhotoViewController
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    
    // Request the photo's URL
    NSURL *url = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
    // Get the image from the URL
    NSData *imgData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imgData];

    // Set the image inside the view
    self.imageView.image = image;

    // Setup the scrollview
    self.scrollView.contentSize = self.imageView.image.size;
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Width ratio compares the width of the viewing area with the width of the image
    float widthRatio = self.scrollView.bounds.size.width / self.imageView.image.size.width;
    
    // Height ratio compares the height of the viewing area with the height of the image
    float heightRatio = self.scrollView.bounds.size.height / self.imageView.image.size.height;
    
    // Update the zoom scale
    self.scrollView.zoomScale = MAX(widthRatio, heightRatio);
    
}

@end
