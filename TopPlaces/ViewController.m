//
//  ViewController.m
//  TopPlaces
//
//  Created by Martin Mandl on 05.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "ViewController.h"
#import "FlickrHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [FlickrHelper loadTopPlacesOnCompletion:^(NSArray *photos, NSError *error) {
        NSLog(@"photos: %@\nerror: %@", photos, error);
    }];
    
}

@end
