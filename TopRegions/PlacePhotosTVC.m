//
//  PlacePhotoTVC.m
//  TopRegions
//
//  Created by Martin Mandl on 06.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "PlacePhotosTVC.h"
#import "FlickrHelper.h"

@interface PlacePhotosTVC ()

@end

@implementation PlacePhotosTVC

#define MAX_PHOTO_RESULTS 50

- (IBAction)fetchPhotos
{
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    
    [FlickrHelper loadPhotosInPlace:self.place
                         maxResults:MAX_PHOTO_RESULTS
                       onCompletion:^(NSArray *photos, NSError *error) {
                           if (!error) {
                               self.photos = photos;
                               [self.refreshControl endRefreshing];
                           } else {
                               NSLog(@"Error loading Photos of %@: %@", self.place, error);
                           }
                       }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPhotos];
}


@end
