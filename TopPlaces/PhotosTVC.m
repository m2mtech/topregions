//
//  PhotosTVC.m
//  TopPlaces
//
//  Created by Martin Mandl on 06.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "PhotosTVC.h"
#import "FlickrHelper.h"
#import "ImageVC.h"
#import "RecentPhotos.h"

@interface PhotosTVC ()

@end

@implementation PhotosTVC

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    NSDictionary *photo = self.photos[indexPath.row];
    cell.textLabel.text = [FlickrHelper titleOfPhoto:photo];
    cell.detailTextLabel.text = [FlickrHelper subtitleOfPhoto:photo];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    [self prepareImageVC:detail
                forPhoto:self.photos[indexPath.row]];
}

#pragma mark - Navigation

- (void)prepareImageVC:(ImageVC *)vc
              forPhoto:(NSDictionary *)photo
{
    vc.imageURL = [FlickrHelper URLforPhoto:photo];
    vc.title = [FlickrHelper titleOfPhoto:photo];
    [RecentPhotos addPhoto:photo];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([segue.identifier isEqualToString:@"Show Photo"] && indexPath) {
        [self prepareImageVC:segue.destinationViewController
                    forPhoto:self.photos[indexPath.row]];
    }
}

@end
