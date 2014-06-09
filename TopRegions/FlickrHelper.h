//
//  FlickrHelper.h
//  TopRegions
//
//  Created by Martin Mandl on 05.12.13.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "FlickrFetcher.h"

typedef void (^RegionCompletionHandler) (NSString *regionName, void(^whenDone)());

#define STARTCELLULARFLICKRFETCHNOTIFICATION @"startCellularFlickrFetch"
#define FINISHEDCELLULARFLICKRFETCHNOTIFICATION @"finishedCellularFlickrFetch"

@interface FlickrHelper : FlickrFetcher

+ (void)handleEventsForBackgroundURLSession:(NSString *)identifier
                          completionHandler:(void (^)())completionHandler;

+ (void)startBackgroundDownloadRecentPhotosOnCompletion:(void (^)(NSArray *photos, void(^whenDone)()))completionHandler
                                 allowingCellularAccess:(BOOL)cellular;

+ (void)loadRecentPhotosOnCompletion:(void (^)(NSArray *places, NSError *error))completionHandler;

+ (void)startBackgroundDownloadRegionForPlaceID:(NSString *)placeID onCompletion:(RegionCompletionHandler)completionHandler;

+ (void)loadTopPlacesOnCompletion:(void (^)(NSArray *places, NSError *error))completionHandler;
+ (void)loadPhotosInPlace:(NSDictionary *)place
               maxResults:(NSUInteger)results
             onCompletion:(void (^)(NSArray *photos, NSError *error))completionHandler;

+ (BOOL)isCellularDownloadSession;

+ (NSString *)countryOfPlace:(NSDictionary *)place;
+ (NSString *)titleOfPlace:(NSDictionary *)place;
+ (NSString *)subtitleOfPlace:(NSDictionary *)place;

+ (NSArray *)sortPlaces:(NSArray *)places;
+ (NSDictionary *)placesByCountries:(NSArray *)places;
+ (NSArray *)countriesFromPlacesByCountry:(NSDictionary *)placesByCountry;

+ (NSString *)titleOfPhoto:(NSDictionary *)photo;
+ (NSString *)subtitleOfPhoto:(NSDictionary *)photo;

+ (NSURL *)URLforPhoto:(NSDictionary *)photo;
+ (NSString *)IDforPhoto:(NSDictionary *)photo;
+ (NSArray *)IDsforPhotos:(NSArray *)photos;
+ (NSURL *)URLforThumbnail:(NSDictionary *)photo;

+ (NSString *)placeIDforPhoto:(NSDictionary *)photo;
+ (NSArray *)placeIDsforPhotos:(NSArray *)photos;

+ (NSString *)ownerOfPhoto:(NSDictionary *)photo;
+ (NSArray *)ownersOfPhotos:(NSArray *)photos;

+ (NSString *)placeIDforPlace:(NSDictionary *)place;

@end
