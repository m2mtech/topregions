//
//  Photographer+Create.m
//  TopRegions
//
//  Created by Martin Mandl on 25.05.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Photographer+Create.h"

@implementation Photographer (Create)

+ (Photographer *)photographerWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context
                 existingPhotographers:(NSMutableArray *)photographers
{
    Photographer *photographer = nil;
    
    if ([name length]) {
        NSArray *matches = [photographers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]];
        
        if (!matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            photographer = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer"
                                                         inManagedObjectContext:context];
            photographer.name = name;
            [photographers addObject:photographer];
        } else {
            photographer = [matches lastObject];
        }
    }
    
    return photographer;
}

@end
