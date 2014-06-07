//
//  RegionPhotoTVC.m
//  TopRegions
//
//  Created by Martin Mandl on 06.12.13.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "RegionPhotosTVC.h"
#import "FlickrHelper.h"
#import "Recent+Photo.h"

@interface RegionPhotosTVC ()

@end

@implementation RegionPhotosTVC

- (void)setRegion:(Region *)region
{
    _region = region;
    self.title = region.name;
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    NSManagedObjectContext *context = self.region.managedObjectContext;
    
    if (context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"region = %@ OR region.name = %@", self.region, self.region.name];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:YES
                                                                   selector:@selector(localizedStandardCompare:)]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - Navigation

- (void)prepareViewController:(id)vc
                     forSegue:(NSString *)segueIdentifer
                fromIndexPath:(NSIndexPath *)indexPath
{
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [Recent recentPhoto:photo];
    
    [super prepareViewController:vc
                        forSegue:segueIdentifer
                   fromIndexPath:indexPath];
}

@end
