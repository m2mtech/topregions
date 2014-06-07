//
//  TopRegionsTVC.m
//  TopRegions
//
//  Created by Martin Mandl on 05.12.13.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "TopRegionsTVC.h"
#import "PhotoDatabaseAvailability.h"

@interface TopRegionsTVC ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation TopRegionsTVC

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

#define NUMBER_OF_SHOWN_REGIONS 50

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = [NSPredicate predicateWithFormat:@"name.length > 0"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"photographerCount"
                                                              ascending:NO
                                 ],[NSSortDescriptor
                                    sortDescriptorWithKey:@"name"
                                    ascending:YES
                                    selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.fetchLimit = NUMBER_OF_SHOWN_REGIONS;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextChanged:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.managedObjectContext];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:self.managedObjectContext];
    [super viewWillDisappear:animated];
}

 - (void)contextChanged:(NSNotification *)notification
{
    [self performFetch];
}

@end
