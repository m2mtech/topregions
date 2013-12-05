//
//  FlickrHelper.h
//  TopPlaces
//
//  Created by Martin Mandl on 05.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "FlickrFetcher.h"

@interface FlickrHelper : FlickrFetcher

+ (void)loadTopPlacesOnCompletion:(void (^)(NSArray *photos, NSError *error))completionHandler;

@end
