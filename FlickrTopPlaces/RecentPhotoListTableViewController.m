//
//  RecentsTableViewController.m
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-13.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "RecentPhotoListTableViewController.h"
#import "PhotoListTableViewController.h"
#import "FlickrPhotoViewController.h"

@interface RecentPhotoListTableViewController ()

@end

@implementation RecentPhotoListTableViewController

#define RECENT_PHOTOS_KEY @"FlickrPhotos.MostRecent"


- (void)viewDidLoad
{
}

- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Load a list of photos from user preferences
    NSArray *recentPhotos = [defaults objectForKey:RECENT_PHOTOS_KEY];
    if(recentPhotos){
        self.photoList = recentPhotos;
    }
    
    // Refresh the table
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateSplitViewDetail
{
    // This subclass doesn't need to update the detail view
    // since we segue directly
    return;
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
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
    if ([segue.identifier isEqualToString:@"Reload Recent Photo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *aPhoto = self.photoList[indexPath.row];
        
        [segue.destinationViewController setPhoto:aPhoto];
    }
}
@end
