//
//  Recent+Photo.m
//  TopRegions
//
//  Created by Martin Mandl on 01.06.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Recent+Photo.h"

@implementation Recent (Photo)

#define RECENT_PHOTOS_MAX_NUMBER 20

+(Recent *)recentPhoto:(Photo *)photo
{
    Recent *recent = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recent"];
    request.predicate = [NSPredicate predicateWithFormat:@"photo = %@", photo];
    NSError *error = nil;
    NSArray *matches = [photo.managedObjectContext executeFetchRequest:request
                                                                 error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if (![matches count]) {
        recent = [NSEntityDescription insertNewObjectForEntityForName:@"Recent"
                                               inManagedObjectContext:photo.managedObjectContext];
        recent.photo = photo;
        recent.lastViewed = [NSDate date];
        
        request.predicate = nil;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastViewed"
                                                                  ascending:NO]];
        matches = [photo.managedObjectContext executeFetchRequest:request
                                                            error:&error];
        if ([matches count] > RECENT_PHOTOS_MAX_NUMBER) {
            [photo.managedObjectContext deleteObject:[matches lastObject]];
        }
    } else {
        recent = [matches lastObject];
        recent.lastViewed = [NSDate date];
    }
    
    return recent;
}

@end