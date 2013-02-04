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
        
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
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
    NSLog(@"callout accessory tapped for annotation %@", [view.annotation title]);
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
    
//    if (splitViewBarButtonItem)
//        [self.navigationItem setLeftBarButtonItem:splitViewBarButtonItem animated:NO];
//    else
//        [self.navigationItem setLeftBarButtonItem:nil animated:NO];
//    
//    _splitViewBarButtonItem = splitViewBarButtonItem;
}

#pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
