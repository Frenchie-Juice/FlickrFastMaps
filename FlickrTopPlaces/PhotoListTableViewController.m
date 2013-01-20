//
//  PlacePhotosTableViewController.m
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-14.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "PhotoListTableViewController.h"
#import "FlickrPhotoViewController.h"
#import "FlickrAPIKey.h"
#import "FlickrFetcher.h"

@interface PhotoListTableViewController ()

@end

@implementation PhotoListTableViewController
@synthesize place = _place;
@synthesize photoList = _photoList;

#define NB_OF_PHOTOS 50
#define RECENTS_MAX_LIST_SIZE 20
#define RECENT_PHOTOS_KEY @"FlickrPhotos.MostRecent"


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

    // Get photos info for this place
    NSArray *photos = [FlickrFetcher photosInPlace:self.place maxResults:NB_OF_PHOTOS];
    
    // We want our photos title sorted alphabetically
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:FLICKR_PHOTO_TITLE
                                                               ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObjects:sortDesc, nil];
    
    // Store the new sorted array
    self.photoList = [photos sortedArrayUsingDescriptors:descriptors];
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
    id detailViewController = [self.splitViewController.viewControllers lastObject];
    if(detailViewController) {
        NSDictionary *aPhoto = self.photoList[indexPath.row];
        
        // Save the photo in the recents list
        [self addPhotoToRecentList:aPhoto];
        
        // Sets the photo to display
        [detailViewController setPhoto:aPhoto];
        
        // Refresh the display of the detail view
        [detailViewController refreshDisplay];
    }
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
