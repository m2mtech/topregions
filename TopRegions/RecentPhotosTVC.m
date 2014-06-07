//
//  RecentPhotosTVC.m
//  TopRegions
//
//  Created by Martin Mandl on 07.12.13.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "RecentPhotosTVC.h"
#import "PhotoDatabaseAvailability.h"

@interface RecentPhotosTVC ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation RecentPhotosTVC

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"recent != nil"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"recent.lastViewed"
                                                              ascending:NO]];    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

@end
