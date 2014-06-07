//
//  Recent.h
//  TopRegions
//
//  Created by Martin Mandl on 25.05.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Recent : NSManagedObject

@property (nonatomic, retain) NSDate * lastViewed;
@property (nonatomic, retain) Photo *photo;

@end
