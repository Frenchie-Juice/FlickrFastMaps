//
//  MapViewController.m
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-30.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "PhotoListMapViewController.h"
#import "FlickrPhotoAnnotation.h"

@interface PhotoListMapViewController() <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation PhotoListMapViewController
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;   // implementation of SplitViewBarButtonItemPresenter protocol
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;

#pragma mark - Synchronize Model and View

- (void)updateMapView
{    
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
    
    // Zoom to the region the photos come from
    if (self.zoomToRegion)
        [self.mapView setRegion: [self.delegate computeMapRegion:self.annotations sender:self] animated:YES];
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        
        // Prepare the left accessory (placeholder for thumbnail)
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
        
        // Prepare the right accessory
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }

    aView.annotation = annotation;
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    // Create spinning 'wait' indicator
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [(UIImageView *)aView.leftCalloutAccessoryView addSubview:spinner];
	[spinner startAnimating];
    
    // Get thumbnail in separate thread
    dispatch_queue_t thumbnailQueue = dispatch_queue_create("thumbnail downloader", NULL);
    dispatch_async(thumbnailQueue, ^{
        NSData *imageData = [self.delegate mapViewController:self imageDataForAnnotation:aView.annotation];
        
        // Update callout view in main thread
		dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            UIImage *image = [UIImage imageWithData:imageData];
            [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
        });
    });
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
        // TODO won't work on iPad anymore
        FlickrPhotoAnnotation *annotation = (FlickrPhotoAnnotation *)view.annotation;
        [self.delegate mapViewController:self displayPhotoForAnnotation:annotation];
}

#pragma mark - Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Annotation Photo"]) {
        NSDictionary *photo = (NSDictionary*)sender;
        // Sets the photo to display
        [segue.destinationViewController setPhoto:photo];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // BUG: The delegate has to be setup in the storyboard as well
    self.mapView.delegate = self;
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
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

#pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


@end
