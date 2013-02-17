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


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
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
