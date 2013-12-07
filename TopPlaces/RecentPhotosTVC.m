//
//  RecentPhotosTVC.m
//  TopPlaces
//
//  Created by Martin Mandl on 07.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "RecentPhotosTVC.h"
#import "RecentPhotos.h"

@interface RecentPhotosTVC ()

@end

@implementation RecentPhotosTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self.photos = [RecentPhotos allPhotos];
}

@end
