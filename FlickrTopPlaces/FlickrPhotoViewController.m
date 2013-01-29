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
#import "DataCache.h"

@interface FlickrPhotoViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *spinnerButton;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIBarButtonItem *splitViewBarButtonItem;
@property (strong, nonatomic) DataCache *photoCache;
@end

@implementation FlickrPhotoViewController
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize toolbar = _toolbar;
@synthesize titleButton = _titleButton;
@synthesize spinnerButton = _spinnerButton;
@synthesize spinner = _spinner;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize photoCache = _photoCache;
@synthesize photo = _photo;


#pragma mark - View Orientation Management

- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
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

#pragma mark - DataCache Management

- (NSString *)findPhotoID
{
    return [self.photo objectForKey:FLICKR_PHOTO_ID];
}

- (NSData *) fetchImageData
{
    // Fetch the image from the cache
    NSData *imgData = [self.photoCache reloadDataFromCacheFile:[self findPhotoID]];
    
    if (!imgData)
        // Retrieve the image from Flickr
        imgData = [NSData dataWithContentsOfURL:
                 [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge]];
    
    return imgData;
}

- (void)storeImageData: (NSData *)data
{
    [self.photoCache storeData:data intoCacheFile:[self findPhotoID]];
}


#pragma mark - ViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.delegate = self;
    self.splitViewController.delegate = self;
    
    self.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.photoCache = [DataCache cacheForFolder:@"FlickrPhotoCache"];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.photo)
        [self refreshDisplay];
}

// Load a photo on screen
- (void)refreshDisplay
{
    // Show the spinner while we load the data from Flickr
    [self.spinner startAnimating];
    
    if (self.splitViewController) // in iPad mode
        self.spinnerButton.customView = self.spinner;
    else // in iPhone mode
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];
    
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(downloadQueue, ^{
        // Retrieve the current image's data
        NSData *imgData = [self fetchImageData];
        
        // Store the data in the cache
        [self storeImageData:imgData];
        
        // UI tasks have to be done on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imgData];
            
            // Set the image inside the view
            self.imageView.image = image;
            
            // Reset the zoom scale back to 1
            self.scrollView.zoomScale = 1;
            
            // Setup the size of the scroll view
            self.scrollView.contentSize = self.imageView.image.size;
            
            // Setup the frame of the image
            self.imageView.frame =
            CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
            
            // Fit the image in the view
            [self fillView];
            
            // Stop the spinner wheel (iPhone mode)
            self.navigationItem.rightBarButtonItem = nil;
            
            // Stop the spinner wheel (iPad mode)
            [self.spinner stopAnimating];
            
            // Set the title of the image on the iPad
            self.titleButton.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
            
        });
    });
}

// Fit as much of the image as possible in the view
- (void)fillView {
    
    // Width ratio compares the width of the viewing area with the width of the image
    float widthRatio = self.view.bounds.size.width / self.imageView.image.size.width;
    
    // Height ratio compares the height of the viewing area with the height of the image
    float heightRatio = self.view.bounds.size.height / self.imageView.image.size.height;
    
    // Update the zoom scale
    self.scrollView.zoomScale = MAX(widthRatio, heightRatio);
    
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Top Places";
    // Tell the detail view to put this button in the toolbar
    self.splitViewBarButtonItem = barButtonItem;
    
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Tell the detail view to put the button away
    self.splitViewBarButtonItem = nil;
}

@end
