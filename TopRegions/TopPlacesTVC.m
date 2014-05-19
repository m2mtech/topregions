//
//  TopPlacesTVC.m
//  TopRegions
//
//  Created by Martin Mandl on 05.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "TopPlacesTVC.h"
#import "FlickrHelper.h"

@interface TopPlacesTVC ()

@end

@implementation TopPlacesTVC

- (IBAction)fetchPlaces
{
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    
    [FlickrHelper loadTopPlacesOnCompletion:^(NSArray *places, NSError *error) {
        if (!error) {
            self.places = places;
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"Error loading TopPlaces: %@", error);
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPlaces];
}

@end
