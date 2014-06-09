//
//  Photo+Flickr.m
//  TopRegions
//
//  Created by Martin Mandl on 25.05.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrHelper.h"
#import "Photographer+Create.h"
#import "Region+Create.h"
#import "Region+Flickr.h"
#import "Recent.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context
         existingPhotographers:(NSMutableArray *)photographers
               existingRegions:(NSMutableArray *)regions
{
    Photo *photo = nil;
    
    NSString *unique = [FlickrHelper IDforPhoto:photoDictionary];
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
//    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
//    NSError *error;
//    NSArray *matches = [context executeFetchRequest:request error:&error];
    
//    if (!matches || error || ([matches count] > 1)) {
        // handle error
//    } else if ([matches count]) {
//        photo = [matches firstObject];
//    } else {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        photo.unique = unique;
        photo.title = [FlickrHelper titleOfPhoto:photoDictionary];
        photo.subtitle = [FlickrHelper subtitleOfPhoto:photoDictionary];
        photo.imageURL = [[FlickrHelper URLforPhoto:photoDictionary] absoluteString];
        photo.thumbnailURL = [[FlickrHelper URLforThumbnail:photoDictionary] absoluteString];
        
        photo.photographer = [Photographer photographerWithName:[FlickrHelper ownerOfPhoto:photoDictionary]
                                         inManagedObjectContext:context
                                          existingPhotographers:photographers];
        
        photo.region = [Region regionWithPlaceID:[FlickrHelper placeIDforPhoto:photoDictionary]
                                 andPhotographer:photo.photographer
                          inManagedObjectContext:context
                                 existingRegions:regions];
    
    photo.created = [NSDate date];
    
//    }
    
    return photo;
}


+ (void)loadPhotosFromFlickrArray:(NSArray *)photos // of Flickr NSDictionary
         intoManagedObjectContext:(NSManagedObjectContext *)context
{
    NSMutableArray *existingPhotographers = [NSMutableArray array];
    NSMutableArray *existingRegions = [NSMutableArray array];
    if ([photos count]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"unique IN %@", [FlickrHelper IDsforPhotos:photos]];
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        if (!matches || ![matches count]) {
            // nothing to do ...
        } else {
            NSArray *existingPhotoIDs = [matches valueForKeyPath:@"unique"];
            NSMutableArray *newPhotos = [NSMutableArray arrayWithCapacity:[photos count] - [matches count]];
            for (NSDictionary *photo in photos) {
                if (![existingPhotoIDs containsObject:[FlickrHelper IDforPhoto:photo]]) {
                    [newPhotos addObject:photo];
                }
            }
            photos = newPhotos;
        }
        
        request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
        request.predicate = [NSPredicate predicateWithFormat:@"name IN %@", [FlickrHelper ownersOfPhotos:photos]];
        existingPhotographers = [[context executeFetchRequest:request error:&error] mutableCopy];
        
        request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = [NSPredicate predicateWithFormat:@"placeID IN %@", [FlickrHelper placeIDsforPhotos:photos]];
        existingRegions = [[context executeFetchRequest:request error:&error] mutableCopy];
    }
    
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo
           inManagedObjectContext:context
            existingPhotographers:existingPhotographers
                  existingRegions:existingRegions];
    }
    
    [Region loadRegionNamesFromFlickrIntoManagedObjectContext:context];
}

#define TIMETOREMOVEOLDPHOTS 60*60*24*7

+ (void)removeOldPhotosFromManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"created < %@", [NSDate dateWithTimeIntervalSinceNow:-TIMETOREMOVEOLDPHOTS]];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error) {
        // handle error
    } else if (![matches count]) {
        // nothing to do
    } else {
        for (Photo *photo in matches) {
            [photo remove];
        }
        [context save:nil];
    }
}

- (void)remove
{
    if ([self.photographer.photos count] == 1) {
        [self.managedObjectContext deleteObject:self.photographer];
    }
    if ([self.region.photos count] == 1) {
        [self.managedObjectContext deleteObject:self.region];
    } else {
        self.region.photographerCount = @([self.region.photographers count]);
        self.region.photoCount = @([self.region.photos count] - 1);
    }
    if (self.recent) {
        [self.managedObjectContext deleteObject:self.recent];
    }
    [self.managedObjectContext deleteObject:self];
}

@end
