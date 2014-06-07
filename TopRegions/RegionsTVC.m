//
//  RegionsTVC.m
//  TopRegions
//
//  Created by Martin Mandl on 05.12.13.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "RegionsTVC.h"
#import "RegionPhotosTVC.h"
#import "Region.h"

@interface RegionsTVC ()

@end

@implementation RegionsTVC

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Region Cell"];
    
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = region.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ photographers %@ photos", region.photographerCount, region.photoCount];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareViewController:(id)vc
                     forSegue:(NSString *)segueIdentifer
                fromIndexPath:(NSIndexPath *)indexPath
{
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([vc isKindOfClass:[RegionPhotosTVC class]]) {
        RegionPhotosTVC *rpTVC = (RegionPhotosTVC *)vc;
        rpTVC.region = region;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController
                       forSegue:segue.identifier
                  fromIndexPath:indexPath];
}

@end
