//
//  Region+Create.h
//  TopRegions
//
//  Created by Martin Mandl on 25.05.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Region.h"

@interface Region (Create)

+ (Region *)regionWithPlaceID:(NSString *)placeID
              andPhotographer:(Photographer *)photographer
       inManagedObjectContext:(NSManagedObjectContext *)context;

@end
