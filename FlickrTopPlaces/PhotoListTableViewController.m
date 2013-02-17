//
//  PhotoListTableViewController.m
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-14.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "PhotoListTableViewController.h"
#import "FlickrPhotoViewController.h"
#import "PhotoListMapViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "FlickrAPIKey.h"
#import "FlickrFetcher.h"

@interface PhotoListTableViewController () <MapViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation PhotoListTableViewController
@synthesize place = _place;
@synthesize photoList = _photoList;
@synthesize spinner = _spinner;

#define NB_OF_PHOTOS 50
#define RECENTS_MAX_LIST_SIZE 20
#define RECENT_PHOTOS_KEY @"FlickrPhotos.MostRecent"

#pragma mark - Load photos and annotations

- (void)setPhotoList:(NSArray *)photoList
{
    if (_photoList != photoList) {
        _photoList = photoList;
        
        // Model changed, so update our View (the table)
        [self.tableView reloadData];
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

- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.photoList count]];
    for (NSDictionary *photo in self.photoList) {
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    return annotations;
}

#pragma mark - IPad detail View Refresh

- (void)updateSplitViewDetail
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSDictionary *aPhoto = self.photoList[indexPath.row];
    
    // Save the photo in the recents list
    [self addPhotoToRecentList:aPhoto];
    
    // Get the detail view controller
    FlickrPhotoViewController *destinationVC = [self splitViewDetailController];
    
    // Sets the photo to display
    [destinationVC setPhoto:aPhoto];
}

- (void)updateSplitViewDetailWithPhoto:(NSDictionary *)photo
{
    // Save the photo in the recents list
    [self addPhotoToRecentList:photo];
    
    // Get the detail view controller
    FlickrPhotoViewController *destinationVC = [self splitViewDetailController];
    
    // Sets the photo to display
    [destinationVC setPhoto:photo];
}

- (FlickrPhotoViewController *)splitViewDetailController
{
    id detail = [self.splitViewController.viewControllers lastObject];
    id photoVC = nil;
    
    // The detail view might be embedded in a Navigation Controller
    if ([detail isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *)detail;
        if ([nc.topViewController isKindOfClass:[FlickrPhotoViewController class]]) {
            photoVC = nc.topViewController;
        }
    }
    // MapViewController directly linked to the SplitViewController
    else if ([detail isKindOfClass:[FlickrPhotoViewController class]]) {
        photoVC = detail;
    }
    
    return photoVC;
}


#pragma mark - MapViewControllerDelegate

// Return a thumbnail image for an annotation
- (NSData *)mapViewController:(PhotoListMapViewController *)sender imageDataForAnnotation:(id <MKAnnotation>)annotation
{
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
    return [FlickrFetcher thumbnailForPhoto:fpa.photo];
}

- (void) mapViewController:(PhotoListMapViewController *)sender displayPhotoForAnnotation:(id<MKAnnotation>)annotation
{
    NSDictionary *photo =  ((FlickrPhotoAnnotation *)annotation).photo;
    if (self.splitViewController) {
        // iPad: update the detail view
        [self updateSplitViewDetailWithPhoto:photo];
    }
    else {
        // iPhone: perform a segue to show the photo
        [self performSegueWithIdentifier:@"Show Single Photo" sender:photo];
    }
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
    [self.spinner startAnimating];
    
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
            [self.spinner stopAnimating];
        });
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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
    
    // Get the photo metadata
    NSDictionary *aPhoto = self.photoList[indexPath.row];
    
    // Create spinning 'wait' indicator
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];

    // Need to create a background image in order to make the spinner visible
    UIImage *whiteBckgnd = [self imageWithColor: [UIColor whiteColor]];
    cell.imageView.image = whiteBckgnd;
    [cell.imageView addSubview:spinner];
    
    // Get thumbnail in separate thread
    dispatch_queue_t thumbnailQueue = dispatch_queue_create("thumbnail downloader", NULL);
    dispatch_async(thumbnailQueue, ^{
        NSData *imageData = [FlickrFetcher thumbnailForPhoto:aPhoto];
        
        // Update cell image view in main thread
		dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            UIImage *image = [UIImage imageWithData:imageData];
            cell.imageView.image = image;
        });
    });
    
    // Set the cell's title
    NSString *title = [aPhoto valueForKey:FLICKR_PHOTO_TITLE];
    cell.textLabel.text = title;
    if ([[title stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        cell.textLabel.text = @"Unknown";
    }
    
    // Set the cell's subtitle
    NSString *description = [aPhoto valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    cell.detailTextLabel.text = description;
    if ([[description stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        cell.detailTextLabel.text = @"No description";
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // on iPhone, a segue shows the photo
    // on iPad, the detail view is refreshed here
    if (self.splitViewController) {
        [self updateSplitViewDetail];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Single Photo"]) {
        NSDictionary *aPhoto = nil;
        // Coming from an annotation accessory click
        if ([sender isKindOfClass:[NSDictionary class]]) {
            aPhoto = (NSDictionary *)sender;
        }
        // Coming from a table click
        else {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            aPhoto = self.photoList[indexPath.row];
        }
        
        // Save the photo in the recents list
        [self addPhotoToRecentList:aPhoto];
        
        // Sets the photo to display
        [segue.destinationViewController setPhoto:aPhoto];
    }
    else if ([segue.identifier isEqualToString:@"Show Photo List Map"]) {
        PhotoListMapViewController *mapVC = segue.destinationViewController;
        mapVC.delegate = self;
        mapVC.zoomToRegion = YES;
        mapVC.annotations = [self mapAnnotations];
        mapVC.title = [self.place objectForKey:FLICKR_PLACE_NAME];
    }
}

#pragma mark - Utility methods
                          
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
                              
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
                              
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
                              
    return image;
}

@end
