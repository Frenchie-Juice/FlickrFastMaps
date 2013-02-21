//
//  RotatableTabBarController.m
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-02-02.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "RotatableTabBarController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface RotatableTabBarController ()
@end

@implementation RotatableTabBarController

#pragma mark - View Life cycle Management

- (void)awakeFromNib  // always try to be the split view's delegate
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

#pragma mark - SplitViewBarButtonItemPresenter

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detail = [self.splitViewController.viewControllers lastObject];
    
    // The detail view might be embedded in a Navigation Controller
    if ([detail isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *)detail;
        detail = nc.topViewController;
        if (![detail conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
            detail = nil;
        }
    }
    // Detail view controller directly linked to the SplitViewController
    else if (![detail conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detail = nil;
    }
    
    return detail;
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Top Places"; //self.title;
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

@end
