//
//  TopPlacesTableViewController.m
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-13.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "PhotoListTableViewController.h"
#import "MapViewController.h"
#import "FlickrAPIKey.h"
#import "FlickrFetcher.h"
#import "FlickrPlaceAnnotation.h"

@interface TopPlacesTableViewController ()
@property (nonatomic, strong) NSArray *topPlaces;
@property (nonatomic, strong) NSDictionary *placesByCountry;
@property (nonatomic, strong) NSArray *sectionHeaders;
@end

@implementation TopPlacesTableViewController
@synthesize topPlaces = _topPlaces;
@synthesize placesByCountry = _placesByCountry;
@synthesize sectionHeaders = _sectionHeaders;


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self loadTopPlaces];
}

- (void)setTopPlaces:(NSArray *)topPlaces
{
    if (_topPlaces != topPlaces) {
        _topPlaces = topPlaces;
        
        [self updateSplitViewDetail];
        // Model changed, so update our View (the table)
        if (self.tableView.window) [self.tableView reloadData];
    }
}

- (void)updateSplitViewDetail
{
    MapViewController *mapVC = [self splitViewMapViewController];
    mapVC.annotations = [self mapAnnotations];
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
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.topPlaces count]];
    for (NSDictionary *place in self.topPlaces) {
        [annotations addObject:[FlickrPlaceAnnotation annotationForPlace:place]];
    }
    return annotations;
}

- (void)loadTopPlaces
{
    // Only load data if not set up already
    if (self.topPlaces) return;
    
    // Create a sorted array of place descriptions
    NSArray *sortDescriptors = [NSArray arrayWithObject:
                                [NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME
                                                              ascending:YES]];
 
    // Show the spinner while we load the data from Flickr
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
    //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
        // Set up the array of top places, organised by place descriptions
        NSArray *topPlaces = [[FlickrFetcher topPlaces]
                              sortedArrayUsingDescriptors:sortDescriptors];
        
        // We want to divide the places up by country, so we can use a dictionary with the country
        // names as key and the places as value
        NSMutableDictionary *placesByCountry = [NSMutableDictionary dictionary];
        
        // For each place
        for (NSDictionary *place in topPlaces) {
            // extract the country name
            NSString *country = [FlickrFetcher parseCountry:place];
            // If the country isn't already in the dictionary, add it with a new array
            if (![placesByCountry objectForKey:country]) {
                [placesByCountry setObject:[NSMutableArray array] forKey:country];
            }
            // Add the place to the countries' value array
            [(NSMutableArray *)[placesByCountry objectForKey:country] addObject:place];
        }
        
        // Execute the remainder in the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            // Set the place by country
            self.placesByCountry = [NSDictionary dictionaryWithDictionary:placesByCountry];
            
            // Set up the section headers in alphabetical order
            self.sectionHeaders = [[placesByCountry allKeys] sortedArrayUsingSelector:
                                   @selector(caseInsensitiveCompare:)];
            
            // Set the top places
            self.topPlaces = topPlaces;
            
            // Stop the spinner wheel
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.sectionHeaders.count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    // Return the header at the given index
    return [self.sectionHeaders objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows for the given section
    return [[self.placesByCountry objectForKey:
             [self.sectionHeaders objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Top Places";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Get a handle the dictionary that contains the selected top place information
    NSDictionary *topPlaceDictionary =
    [[self.placesByCountry objectForKey:
      [self.sectionHeaders objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    // Get the place property from the dictionary
    NSString *place = [topPlaceDictionary objectForKey:FLICKR_PLACE_NAME];
    
    NSRange commaRange = [place rangeOfString:@","];
    if (commaRange.location == NSNotFound) {
        cell.textLabel.text = place;
        cell.detailTextLabel.text = @"";
    } else {
        cell.textLabel.text = [place substringToIndex:commaRange.location];
        cell.detailTextLabel.text = [place substringFromIndex:commaRange.location +1];
    }
    
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

#pragma mark - Prepare Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Place Photos"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        // Identify the selected place from within the places by country dictionary
        NSDictionary *aPlace =
        [[self.placesByCountry valueForKey:
          [self.sectionHeaders objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        [segue.destinationViewController setPlace:aPlace];
    }
}


@end
