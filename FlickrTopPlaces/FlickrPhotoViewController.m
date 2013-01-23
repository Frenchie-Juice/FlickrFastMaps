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
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleButton;
@property (strong, nonatomic) UIBarButtonItem *splitViewBarButtonItem;
@end

@implementation FlickrPhotoViewController
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize toolbar = _toolbar;
@synthesize titleButton = _titleButton;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

// Puts the splitViewBarButton in our toolbar (and/or removes the old one).
// Must be called when our splitViewBarButtonItem property changes
//  (and also after our view has been loaded from the storyboard (viewDidLoad)).

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.delegate = self;
    self.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    
    [self updateView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self fillView];
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

// On the iPad, this method is used to display the photo
// It does the same job as viewDidLoad and viewWillAppear
- (void)refreshDisplay
{
    // Set up the view
    [self updateView];
    
    // Set the zoom level of the view to fill up the screen
    [self fillView];
}

// On the iPad, viewDidLoad has already been called so this method
// does the same job of querying and displaying the photo
- (void)updateView {
    
    // Request the photo's URL
    NSURL *url = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
    // Get the image from the URL
    NSData *imgData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imgData];
    
    // Set the image inside the view
    self.imageView.image = image;
    
    // Set the title of the image
    self.titleButton.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    
    // Reset the zoom scale back to 1
    self.scrollView.zoomScale = 1;
    
    // Setup the size of the scroll view
    self.scrollView.contentSize = self.imageView.image.size;
    
    // Setup the frame of the image
    self.imageView.frame =
    CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
}

// On the iPad, viewWillAppear has already been called so this method
// does the same job of displaying the photo as large as possible
- (void)fillView {
    
    // Width ratio compares the width of the viewing area with the width of the image
    float widthRatio = self.view.bounds.size.width / self.imageView.image.size.width;
    
    // Height ratio compares the height of the viewing area with the height of the image
    float heightRatio = self.view.bounds.size.height / self.imageView.image.size.height;
    
    // Update the zoom scale
    self.scrollView.zoomScale = MAX(widthRatio, heightRatio);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
