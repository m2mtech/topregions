//
//  PlacesTVC.m
//  TopPlaces
//
//  Created by Martin Mandl on 05.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "PlacesTVC.h"
#import "FlickrHelper.h"

@interface PlacesTVC ()

@property (nonatomic, strong) NSDictionary *placesByCountry;
@property (nonatomic, strong) NSArray *countries;

@end

@implementation PlacesTVC

- (void)setPlaces:(NSArray *)places
{
    if (_places == places) return;
    
    _places = [FlickrHelper sortPlaces:places];
    
    self.placesByCountry = [FlickrHelper placesByCountries:_places];
    self.countries = [FlickrHelper countriesFromPlacesByCountry:self.placesByCountry];

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.countries count];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return self.countries[section];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.placesByCountry[self.countries[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    NSDictionary *place = self.placesByCountry[self.countries[indexPath.section]][indexPath.row];
    cell.textLabel.text = [FlickrHelper titleOfPlace:place];
    cell.detailTextLabel.text = [FlickrHelper subtitleOfPlace:place];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
