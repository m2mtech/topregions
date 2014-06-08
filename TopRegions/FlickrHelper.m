//
//  FlickrHelper.m
//  TopRegions
//
//  Created by Martin Mandl on 05.12.13.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "FlickrHelper.h"

@interface FlickrHelper() <NSURLSessionDownloadDelegate>

@property (strong, nonatomic) NSURLSession *downloadSession;
@property (strong, nonatomic) NSURLSession *cellularDownloadSession;
@property (strong, nonatomic) NSURLSession *currentDownloadSession;
@property (nonatomic) BOOL allowingCellularAccess;

@property (copy, nonatomic) void (^downloadBackgroundURLSessionCompletionHandler)();
@property (copy, nonatomic) void (^recentPhotosCompletionHandler)(NSArray *photos, void(^whenDone)());
//@property (copy, nonatomic) void (^regionCompletionHandler)(NSString *regionName, void(^whenDone)());
@property (strong, nonatomic) NSMutableDictionary *regionCompletionHandlers;

@end

#define FLICKR_FETCH @"Flickr Download Session"
#define FLICKR_FETCH_CELLULAR @"Cellular Flickr Download Session"
#define FLICKR_FETCH_RECENT_PHOTOS @"Flickr Download Task to Download Recent Photos"
#define FLICKR_FETCH_REGION @"Flickr Download Task to Download Region"
#define BACKGROUND_FLICKR_FETCH_TIMEOUT 10

@implementation FlickrHelper

- (NSMutableDictionary *)regionCompletionHandlers
{
    if (!_regionCompletionHandlers) {
        _regionCompletionHandlers = [[NSMutableDictionary alloc] init];
    }
    return _regionCompletionHandlers;
}

- (NSURLSession *)downloadSession
{
    if (!_downloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];
            config.allowsCellularAccess = NO;
            _downloadSession = [NSURLSession sessionWithConfiguration:config
                                                             delegate:self
                                                        delegateQueue:nil];
        });
    }
    return _downloadSession;
}

- (NSURLSession *)cellularDownloadSession
{
    if (!_cellularDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH_CELLULAR];
            config.allowsCellularAccess = YES;
            _cellularDownloadSession = [NSURLSession sessionWithConfiguration:config
                                                             delegate:self
                                                        delegateQueue:nil];
        });
    }
    return _cellularDownloadSession;
}

- (NSURLSession *)currentDownloadSession
{
    if (self.allowingCellularAccess) return self.cellularDownloadSession;
    return self.downloadSession;
}

+ (FlickrHelper *)sharedFlickrHelper
{
    static dispatch_once_t pred = 0;
    __strong static FlickrHelper *_sharedFlickrHelper = nil;
    dispatch_once(&pred, ^{
        _sharedFlickrHelper = [[self alloc] init];
    });
    return _sharedFlickrHelper;
}

+ (void)handleEventsForBackgroundURLSession:(NSString *)identifier
                          completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:FLICKR_FETCH]) {
        FlickrHelper *fh = [FlickrHelper sharedFlickrHelper];
        fh.downloadBackgroundURLSessionCompletionHandler = completionHandler;
    }
}

+ (BOOL)isCellularDownloadSession
{
    FlickrHelper *fh = [FlickrHelper sharedFlickrHelper];
    return fh.currentDownloadSession.configuration.allowsCellularAccess;
}

+ (void)startBackgroundDownloadRecentPhotosOnCompletion:(void (^)(NSArray *photos, void(^whenDone)()))completionHandler
                                 allowingCellularAccess:(BOOL)cellular
{
    FlickrHelper *fh = [FlickrHelper sharedFlickrHelper];
    fh.allowingCellularAccess = cellular;
    NSURLSession *session = fh.currentDownloadSession;
    [session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH_RECENT_PHOTOS;
            fh.recentPhotosCompletionHandler = completionHandler;
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
}

+ (void)startBackgroundDownloadRegionForPlaceID:(NSString *)placeID onCompletion:(RegionCompletionHandler)completionHandler
{
    FlickrHelper *fh = [FlickrHelper sharedFlickrHelper];
    NSURLSession *session = fh.currentDownloadSession;
    [session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[FlickrFetcher URLforInformationAboutPlace:placeID]];
        task.taskDescription = FLICKR_FETCH_REGION;
        [fh.regionCompletionHandlers setObject:[completionHandler copy]
                                        forKey:[NSString stringWithFormat:@"%@%d", session.description, task.taskIdentifier]];
        [task resume];
    }];
}

+ (void)loadRecentPhotosOnCompletion:(void (^)(NSArray *places, NSError *error))completionHandler
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    config.allowsCellularAccess = NO;
    [FlickrHelper sharedFlickrHelper].allowingCellularAccess = NO;
    config.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_TIMEOUT;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[FlickrHelper URLforRecentGeoreferencedPhotos]
                                                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                    NSArray *photos;
                                                    if (!error) {
                                                        photos = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location]
                                                                                                  options:0
                                                                                                    error:&error] valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                                                    }
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        completionHandler(photos, error);
                                                    });
                                                }];
    [task resume];
}

+ (void)loadTopPlacesOnCompletion:(void (^)(NSArray *places, NSError *error))completionHandler
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[FlickrHelper URLforTopPlaces]
                                                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                    NSArray *places;
                                                    if (!error) {
                                                        places = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location]
                                                                                                 options:0
                                                                                                   error:&error] valueForKeyPath:FLICKR_RESULTS_PLACES];
                                                    }
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        completionHandler(places, error);
                                                    });
                                                }];
    [task resume];
}

+ (void)loadPhotosInPlace:(NSDictionary *)place
               maxResults:(NSUInteger)results
             onCompletion:(void (^)(NSArray *photos, NSError *error))completionHandler
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[FlickrHelper URLforPhotosInPlace:[place valueForKeyPath:FLICKR_PLACE_ID] maxResults:(int)results]
                                                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                    NSArray *photos;
                                                    if (!error) {
                                                        photos = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location]
                                                                                                  options:0
                                                                                                    error:&error] valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                                                    }
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        completionHandler(photos, error);
                                                    });
                                                }];
    [task resume];
}

+ (NSString *)titleOfPlace:(NSDictionary *)place
{
    return [[[place valueForKeyPath:FLICKR_PLACE_NAME]
             componentsSeparatedByString:@", "] firstObject];
}

+ (NSString *)subtitleOfPlace:(NSDictionary *)place
{
    NSArray *nameParts = [[place valueForKeyPath:FLICKR_PLACE_NAME]
                          componentsSeparatedByString:@", "];
    NSRange range;
    range.location = 1;
    range.length = [nameParts count] - 2;
    return [[nameParts subarrayWithRange:range] componentsJoinedByString:@", "];
}

+ (NSString *)countryOfPlace:(NSDictionary *)place
{
    return [[[place valueForKeyPath:FLICKR_PLACE_NAME]
             componentsSeparatedByString:@", "] lastObject];
}

+ (NSArray *)sortPlaces:(NSArray *)places
{
    return [places sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *name1 = [obj1 valueForKeyPath:FLICKR_PLACE_NAME];
        NSString *name2 = [obj2 valueForKeyPath:FLICKR_PLACE_NAME];
        return [name1 localizedCompare:name2];
    }];
}

+ (NSDictionary *)placesByCountries:(NSArray *)places
{
    NSMutableDictionary *placesByCountry = [NSMutableDictionary dictionary];
    for (NSDictionary *place in places) {
        NSString *country = [FlickrHelper countryOfPlace:place];
        NSMutableArray *placesOfCountry = placesByCountry[country];
        if (!placesOfCountry) {
            placesOfCountry = [NSMutableArray array];
            placesByCountry[country] = placesOfCountry;
        }
        [placesOfCountry addObject:place];
    }
    return placesByCountry;
}

+ (NSArray *)countriesFromPlacesByCountry:(NSDictionary *)placesByCountry
{
    NSArray *countries = [placesByCountry allKeys];
    countries = [countries sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSCaseInsensitiveSearch];
    }];
    return countries;
}

#define FLICKR_UNKNOWN_PHOTO_TITLE @"Unknown"

+ (NSString *)titleOfPhoto:(NSDictionary *)photo
{
    NSString *title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    if ([title length]) return title;
    
    title = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if ([title length]) return title;
    
    return FLICKR_UNKNOWN_PHOTO_TITLE;
}

+ (NSString *)subtitleOfPhoto:(NSDictionary *)photo
{
    NSString *title = [FlickrHelper titleOfPhoto:photo];
    if ([title isEqualToString:FLICKR_UNKNOWN_PHOTO_TITLE]) return @"";
    
    NSString *subtitle = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if ([title isEqualToString:subtitle]) return @"";
    
    return subtitle;
}

+ (NSURL *)URLforPhoto:(NSDictionary *)photo
{
    return [FlickrHelper URLforPhoto:photo format:FlickrPhotoFormatLarge];
}

+ (NSURL *)URLforThumbnail:(NSDictionary *)photo
{
    return [FlickrHelper URLforPhoto:photo format:FlickrPhotoFormatSquare];
}

+ (NSString *)IDforPhoto:(NSDictionary *)photo
{
    return [photo valueForKeyPath:FLICKR_PHOTO_ID];
}

+ (NSString *)placeIDforPhoto:(NSDictionary *)photo
{
    return [photo valueForKeyPath:FLICKR_PHOTO_PLACE_ID];
}

+ (NSString *)ownerOfPhoto:(NSDictionary *)photo
{
    return [photo valueForKeyPath:FLICKR_PHOTO_OWNER];
}

#define FLICKR_PLACE_PLACE_ID @"place.place_id"

+ (NSString *)placeIDforPlace:(NSDictionary *)place
{
    return [place valueForKeyPath:FLICKR_PLACE_PLACE_ID];
}


#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH_RECENT_PHOTOS]) {
        NSDictionary *flickrPropertyList;
        NSData *flickrJSONData = [NSData dataWithContentsOfURL:location];
        if (flickrJSONData) {
            flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                                 options:0
                                                                   error:NULL];
        }
        NSArray *photos = [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        
        self.recentPhotosCompletionHandler(photos, ^{
            [self downloadTasksMightBeComplete];
        });
    } else if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH_REGION]) {
        NSDictionary *flickrPropertyList;
        NSData *flickrJSONData = [NSData dataWithContentsOfURL:location];
        if (flickrJSONData) {
            flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                                 options:0
                                                                   error:NULL];
        }

        NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:flickrPropertyList];
        RegionCompletionHandler regionCompletionHandler = [self.regionCompletionHandlers[[NSString stringWithFormat:@"%@%d", session.description, downloadTask.taskIdentifier]] copy];
        if (regionCompletionHandler) {
            regionCompletionHandler(regionName, ^{
                [self downloadTasksMightBeComplete];
            });            
        }
        [self.regionCompletionHandlers removeObjectForKey:@(downloadTask.taskIdentifier)];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    if (error) {
        NSLog(@"Flickr background download session failed: %@", error.localizedDescription);
        [self downloadTasksMightBeComplete];
    }
}

- (void)downloadTasksMightBeComplete
{
    if (self.downloadBackgroundURLSessionCompletionHandler) {
        NSURLSession *session = self.currentDownloadSession;
        [session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                void (^completionHandler)() = self.downloadBackgroundURLSessionCompletionHandler;
                self.downloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            }
        }];
    }
}


@end
