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
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) DataCache *photoCache;
@end

@implementation FlickrPhotoViewController
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;   // implementation of SplitViewBarButtonItemPresenter protocol
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize spinner = _spinner;
@synthesize photoCache = _photoCache;
@synthesize photo = _photo;

#pragma mark - Getters and Setters
- (void)setPhoto:(NSDictionary *)photo
{
    _photo = photo;
    
    // Model changed, update our view
    [self refreshDisplay];
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
    
    // Create the spinner button
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];

    // Create the photo cache
    self.photoCache = [DataCache cacheForFolder:@"FlickrPhotoCache"];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.photo)
        [self refreshDisplay];
}

// Load a photo on screen
- (void)refreshDisplay
{
    // Setup a title that fits on screen
    NSString *title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    title = [title substringToIndex: MIN(25, [title length])];
    self.title = title;
    
    // Show the spinner while we load the data from Flickr
    [self.spinner startAnimating];
    
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
            
            // Stop the spinner wheel
            [self.spinner stopAnimating];
            
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

#pragma mark - SplitViewBarButtonItemPresenter

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [[self.navigationItem leftBarButtonItems] mutableCopy];
    if (!toolbarItems) {
        toolbarItems = [[NSMutableArray alloc] init];
    }
    
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    [self.navigationItem setLeftBarButtonItems:toolbarItems];
    
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

@end
