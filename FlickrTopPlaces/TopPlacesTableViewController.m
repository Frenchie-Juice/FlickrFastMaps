//
//  TopPlacesTableViewController.m
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-13.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "PhotoListTableViewController.h"
#import "FlickrAPIKey.h"
#import "FlickrFetcher.h"

@interface TopPlacesTableViewController ()
@property (nonatomic, strong) NSArray *topPlaces;
@property (nonatomic, strong) NSDictionary *placesByCountry;
@property (nonatomic, strong) NSArray *sectionHeaders;
@end

@implementation TopPlacesTableViewController
@synthesize topPlaces = _topPlaces;
@synthesize placesByCountry = _placesByCountry;
@synthesize sectionHeaders = _sectionHeaders;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NSLog(@"Nb of places: %u", self.topPlaces.count);
    [self loadTopPlaces];
}

- (void)loadTopPlaces {
    
    // Only load data if not set up already
    if (self.topPlaces) return;
    
    // Create a sorted array of place descriptions
    NSArray *sortDescriptors = [NSArray arrayWithObject:
                                [NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME
                                                              ascending:YES]];
    
    // Set up the array of top places, organised by place descriptions
    self.topPlaces = [[FlickrFetcher topPlaces]
                      sortedArrayUsingDescriptors:sortDescriptors];
    
    
    // We want to divide the places up by country, so we can use a dictionary with the country
    // names as key and the places as value
    NSMutableDictionary *placesByCountry = [NSMutableDictionary dictionary];
    
    // For each place
    for (NSDictionary *place in self.topPlaces) {
        // extract the country name
        NSString *country = [self parseForCountry:place];
        // If the country isn't already in the dictionary, add it with a new array
        if (![placesByCountry objectForKey:country]) {
            [placesByCountry setObject:[NSMutableArray array] forKey:country];
        }
        // Add the place to the countries' value array
        [(NSMutableArray *)[placesByCountry objectForKey:country] addObject:place];
    }
    
    // Set the place by country
    self.placesByCountry = [NSDictionary dictionaryWithDictionary:placesByCountry];
    
    // Set up the section headers in alphabetical order
    self.sectionHeaders = [[placesByCountry allKeys] sortedArrayUsingSelector:
                           @selector(caseInsensitiveCompare:)];
}

- (NSString *)parseForCountry: (NSDictionary *) topPlace {
    
    // Get the place information from the given topPlace
    NSString *placeInformation = [topPlace objectForKey:FLICKR_PLACE_NAME];
    
    // Search the place information for the last comma.
    NSRange lastComma = [placeInformation rangeOfString:@"," options:NSBackwardsSearch];
    
    // Return the text that comes after the last comma
    if (lastComma.location != NSNotFound) {
        return [placeInformation substringFromIndex:lastComma.location + 2];
    } else return @"";
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
