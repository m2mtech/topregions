//
//  RecentPhotos.h
//  TopRegions
//
//  Created by Martin Mandl on 07.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentPhotos : NSObject

+ (NSArray *)allPhotos;
+ (void)addPhoto:(NSDictionary *)photo;

@end
