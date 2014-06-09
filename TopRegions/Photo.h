//
//  Photo.h
//  TopRegions
//
//  Created by Martin Mandl on 09.06.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer, Recent, Region;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) Photographer *photographer;
@property (nonatomic, retain) Recent *recent;
@property (nonatomic, retain) Region *region;

@end
