//
//  PlacePhotosTableViewController.m
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-14.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "PhotoListTableViewController.h"
#import "FlickrPhotoViewController.h"
#import "MapViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "FlickrAPIKey.h"
#import "FlickrFetcher.h"

@interface PhotoListTableViewController () <MapViewControllerDelegate>
@end

@implementation PhotoListTableViewController
@synthesize place = _place;
@synthesize photoList = _photoList;

#define NB_OF_PHOTOS 50
#define RECENTS_MAX_LIST_SIZE 20
#define RECENT_PHOTOS_KEY @"FlickrPhotos.MostRecent"


- (void)setPhotoList:(NSArray *)photoList
{
    if (_photoList != photoList) {
        _photoList = photoList;
        
        // Update the detail view
        [self updateSplitViewDetail];
        // Model changed, so update our View (the table)
        [self.tableView reloadData];
    }
}

- (void)updateSplitViewDetail
{
    MapViewController *mapVC = [self splitViewMapViewController];
    mapVC.delegate = self;
    mapVC.zoomToRegion = YES;
    mapVC.annotations = [self mapAnnotations];
    mapVC.title = [self.place objectForKey:FLICKR_PLACE_NAME];
}

- (MapViewController *)splitViewMapViewController
{
    id detail = [self.splitViewController.viewControllers lastObject];
    id mapVC = nil;
    
    // The detail view might be embedded in a Navigation Controller
    if ([detail isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *)detail;
        if ([nc.topViewController isKindOfClass:[MapViewController class]]) {
            mapVC = nc.topViewController;
        }
    }
    // MapViewController directly linked to the SplitViewController
    else if ([detail isKindOfClass:[MapViewController class]]) {
        mapVC = detail;
    }
    
    return mapVC;
}

- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.photoList count]];
    for (NSDictionary *photo in self.photoList) {
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    return annotations;
}

#pragma mark - MapViewControllerDelegate

// Return a thumbnail image for an annotation
- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
    NSURL *url = [FlickrFetcher  urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    return data ? [UIImage imageWithData:data] : nil;
}

// Compute the region to show on the map for annotations
-(MKCoordinateRegion) computeMapRegion:(NSArray *)annotations sender:(id)sender
{
    MKCoordinateRegion region;
    CLLocationDegrees minLatitude = 100.0f;    // -90 < lat < 90
    CLLocationDegrees minLongitude = 200.0f;   // -180 < lon < 180
    CLLocationDegrees maxLatitude = -100.0f;
    CLLocationDegrees maxLongitude = -200.0f;
    
    for (NSDictionary *photo in self.photoList)
    {
        CLLocationDegrees photoLat = [[photo objectForKey:FLICKR_LATITUDE] doubleValue];
        CLLocationDegrees photoLon = [[photo objectForKey:FLICKR_LONGITUDE] doubleValue];
        //NSLog(@"Lat: %f  Lon: %f",photoLat,photoLon);
        
        if (photoLat < minLatitude) minLatitude = photoLat;
        if (photoLat > maxLatitude) maxLatitude = photoLat;
        if (photoLon < minLongitude) minLongitude = photoLon;
        if (photoLon > maxLongitude) maxLongitude = photoLon;
    }
    CLLocation *lowerLeft = [[CLLocation alloc]initWithLatitude:minLatitude longitude:minLongitude];
    CLLocation *upperRight = [[CLLocation alloc]initWithLatitude:maxLatitude longitude:maxLongitude];
    
    CLLocationDistance distance = 2.0 *  [lowerLeft distanceFromLocation:upperRight];
    
    // Minimum distance is 1000 meters
    if (distance < 1000.0)
    {
        distance = 1000.0;
    }
    
    CLLocationCoordinate2D midPoint = CLLocationCoordinate2DMake((minLatitude + maxLatitude)/2.0, (minLongitude + maxLongitude)/2.0);
    region= MKCoordinateRegionMakeWithDistance(midPoint, distance, distance);
    
    return region;    
}

#pragma mark - View Controller Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];

    // Show the spinner while we load the data from Flickr
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    // Get photos info for this place and query in a different thread
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher photosInPlace:self.place maxResults:NB_OF_PHOTOS];
        
        // We want our photos title sorted alphabetically
        NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:FLICKR_PHOTO_TITLE
                                                                   ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObjects:sortDesc, nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Store the new sorted array
            self.photoList = [photos sortedArrayUsingDescriptors:descriptors];
            // Stop the spinning wheel
            self.navigationItem.rightBarButtonItem = nil;
        });
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.photoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place Photos";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *aPhoto = self.photoList[indexPath.row];
    
    NSString *title = [aPhoto valueForKey:FLICKR_PHOTO_TITLE];
    NSString *description = [aPhoto valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    cell.textLabel.text = title;
    if ([[title stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        cell.textLabel.text = @"Unknown";
    }
         
    cell.detailTextLabel.text = description;
    if ([[description stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        cell.detailTextLabel.text = @"No description";
    }
         
    //NSLog(@"%@", aPhoto);
    

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Single Photo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *aPhoto = self.photoList[indexPath.row];
        
        // Save the photo in the recents list
        [self addPhotoToRecentList:aPhoto];
        
        // Sets the photo to display
        [segue.destinationViewController setPhoto:aPhoto];
    }
}

- (void)addPhotoToRecentList:(NSDictionary *)aPhoto
{
    // Get the user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Get an array of recent photos
    NSMutableArray *recentPhotos = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    if(!recentPhotos)recentPhotos = [NSMutableArray array];
    
    // Get the unique photo ID
    NSString *photoId = [aPhoto objectForKey:FLICKR_PHOTO_ID];
    
    // We check if the photo is already in the list of most recent
    for (NSDictionary *photo in recentPhotos) {
        if ([[photo objectForKey:FLICKR_PHOTO_ID] isEqualToString:photoId]) {
            // Remove the old photo
            [recentPhotos removeObject:photo];
            break;
        }
    }
    // Add the new photo at the top of the list
    [recentPhotos insertObject:aPhoto atIndex:0];
    
    // Check that we don't exceed the allowed number of recent photos
    if (recentPhotos.count > RECENTS_MAX_LIST_SIZE) {
        [recentPhotos removeObjectAtIndex:RECENTS_MAX_LIST_SIZE];
    }
    
    // Store the new array of most recent photos
    [defaults setObject:recentPhotos
                 forKey:RECENT_PHOTOS_KEY];
    [defaults synchronize];
}


@end
