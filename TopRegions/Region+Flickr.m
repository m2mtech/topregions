//
//  Region+Flickr.m
//  TopRegions
//
//  Created by Martin Mandl on 25.05.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Region+Flickr.h"
#import "FlickrHelper.h"
#import "DocumentHelper.h"

@implementation Region (Flickr)

+ (void)loadRegionNamesFromFlickrIntoManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = [NSPredicate predicateWithFormat:@"name.length = %@", nil];

    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if (!matches || ![matches count]) {
        // nothing to do ...
        [[NSNotificationCenter defaultCenter] postNotificationName:FINISHEDCELLULARFLICKRFETCHNOTIFICATION
                                                            object:self];
    } else {
        BOOL saveDocument = NO;
        
        for (Region *match in matches) {
            if ([match isEqual:[matches lastObject]]) {
                saveDocument = YES;
            }
            
            [FlickrHelper startBackgroundDownloadRegionForPlaceID:match.placeID
                                                     onCompletion:^(NSString *regionName, void (^whenDone)()) {
                [DocumentHelper useDocumentWithOperation:^(UIManagedDocument *document, BOOL success) {
                    if (success) {
                        [document.managedObjectContext performBlock:^{
                            Region *region = nil;
                            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
                            request.predicate = [NSPredicate predicateWithFormat:@"placeID = %@", match.placeID];
                            
                            NSError *error;
                            NSArray *matches = [document.managedObjectContext executeFetchRequest:request
                                                                                            error:&error];
                            if (!matches || ([matches count] != 1)) {
                                // handle error
                            } else {
                                region = [matches lastObject];
                                
                                request.predicate = [NSPredicate predicateWithFormat:@"name = %@", regionName];
                                matches = [document.managedObjectContext executeFetchRequest:request
                                                                                       error:&error];
                                if (!matches) {
                                    // handle error
                                } else if (![matches count]) {
                                    region.name = regionName;
                                } else {
                                    region.name = regionName;
                                    for (Region *match in matches) {
                                        region.photos = [region.photos setByAddingObjectsFromSet:match.photos];
                                        region.photoCount = @([region.photos count]);
                                        region.photographers = [region.photographers setByAddingObjectsFromSet:match.photographers];
                                        region.photographerCount = @([region.photographers count]);
                                        [document.managedObjectContext deleteObject:match];
                                    }
                                }
                                if (saveDocument) {
                                    [document saveToURL:document.fileURL
                                       forSaveOperation:UIDocumentSaveForOverwriting
                                      completionHandler:nil];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:FINISHEDCELLULARFLICKRFETCHNOTIFICATION
                                                                                        object:self];
                                }
                        }
                        if (whenDone) whenDone();
                        }];
                    } else {
                        if (whenDone) whenDone();
                    }
                }];
            }];
        }
    }
}

@end
