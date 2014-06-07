//
//  Region+Flickr.h
//  TopRegions
//
//  Created by Martin Mandl on 25.05.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Region.h"

@interface Region (Flickr)

+ (void)loadRegionNamesFromFlickrIntoManagedObjectContext:(NSManagedObjectContext *)context;

@end
