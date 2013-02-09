//
//  MapViewController.m
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-30.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "MapViewController.h"
#import "FlickrPhotoAnnotation.h"

@interface MapViewController() <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapViewController
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;   // implementation of SplitViewBarButtonItemPresenter protocol
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;

#pragma mark - Synchronize Model and View

- (void)updateMapView
{
    // Zoom to the region the photos come from
    if (self.zoomToRegion)
        [self.mapView setRegion: [self.delegate computeMapRegion:self.annotations sender:self] animated:YES];
    
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
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
    if (aView.leftCalloutAccessoryView != nil) {
        UIImage *image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
        [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[FlickrPlaceAnnotation class]]) {
        // Click on a place pin --> zoom to show the photo annotations
        NSLog(@"callout accessory tapped for place %@", [view.annotation title]);
    }
    else {
        // Click on a photo pin --> show the photo
        FlickrPhotoAnnotation *annotation = (FlickrPhotoAnnotation *)view.annotation;
        NSDictionary *photo = annotation.photo;
        [self performSegueWithIdentifier:@"Show Annotation Photo" sender:photo];        
    }
    
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
