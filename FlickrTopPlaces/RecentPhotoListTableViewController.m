//
//  RecentPhotoListTableViewController.m
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-13.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "RecentPhotoListTableViewController.h"
#import "PhotoListTableViewController.h"
#import "PhotoListMapViewController.h"
#import "FlickrPhotoViewController.h"
#import "FlickrPhotoAnnotation.h"

@interface RecentPhotoListTableViewController ()

@end

@implementation RecentPhotoListTableViewController

#define RECENT_PHOTOS_KEY @"FlickrPhotos.MostRecent"


- (void)viewDidLoad
{
    [super viewDidLoad];
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

#pragma mark - MapViewControllerDelegate

- (void) mapViewController:(PhotoListMapViewController *)sender displayPhotoForAnnotation:(id<MKAnnotation>)annotation
{
    NSDictionary *photo =  ((FlickrPhotoAnnotation *)annotation).photo;
    if (self.splitViewController) {
        // iPad: update the detail view
        [self updateSplitViewDetailWithPhoto:photo];
    }
    else {
        // iPhone: perform a segue to show the photo
        [self performSegueWithIdentifier:@"Reload Recent Photo" sender:photo];
    }
}


#pragma mark - Prepare Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Reload Recent Photo"]) {
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
        
        // Set the photo to display
        [segue.destinationViewController setPhoto:aPhoto];
    }
    else if ([segue.identifier isEqualToString:@"Reload Recent Photos Map"]) {
        PhotoListMapViewController *mapVC = segue.destinationViewController;
        mapVC.delegate = self;
        mapVC.zoomToRegion = YES;
        mapVC.annotations = [self mapAnnotations];
        mapVC.title = @"Recent Places";
    }    
}
@end
