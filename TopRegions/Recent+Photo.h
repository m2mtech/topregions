//
//  Recent+Photo.h
//  TopRegions
//
//  Created by Martin Mandl on 01.06.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Recent.h"
#import "Photo.h"

@interface Recent (Photo)

+ (Recent *)recentPhoto:(Photo *)photo;

@end
