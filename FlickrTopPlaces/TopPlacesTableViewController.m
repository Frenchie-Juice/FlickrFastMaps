//
//  TopPlacesTableViewController.m
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-13.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "PlacePhotosTableViewController.h"
#import "FlickrAPIKey.h"
#import "FlickrFetcher.h"

@interface TopPlacesTableViewController ()
@property (nonatomic, strong) NSArray *topPlaces;
@end

@implementation TopPlacesTableViewController
@synthesize topPlaces = _topPlaces;


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

    // Query Flickr for top places
    NSArray *allPlaces = [FlickrFetcher topPlaces];
    
    // We want our places sorted alphabetically
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObjects:sortDesc, nil];

    // Store the new sorted array
    self.topPlaces = [allPlaces sortedArrayUsingDescriptors:descriptors];
    
    //NSLog(@"Nb of places: %u", self.topPlaces.count);

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

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.topPlaces.count;
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
    
    // Get the info for the place at this index
    NSDictionary *aPlace = self.topPlaces[indexPath.row];
    // Get the place property from the dictionary
    NSString *place = [aPlace objectForKey:FLICKR_PLACE_NAME];
    
    NSRange commaRange = [place rangeOfString:@","];
    cell.textLabel.text = [place substringToIndex:commaRange.location];
    cell.detailTextLabel.text = [place substringFromIndex:commaRange.location +1];
    
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
        NSDictionary *aPlace = self.topPlaces[indexPath.row];
        
        [segue.destinationViewController setPlace:aPlace];
    }
}


@end
