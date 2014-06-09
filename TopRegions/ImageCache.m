//
//  ImageCache.m
//  TopRegions
//
//  Created by Martin Mandl on 09.06.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "ImageCache.h"

@interface ImageCache ()

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSURL *folder;
@property (nonatomic, strong) NSURL *url;

@end

@implementation ImageCache

#define IMAGECACHE_FOLDER @"imageCache"

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super self];
    if (self) {
        _fileManager = [[NSFileManager alloc] init];
        _folder = [[[_fileManager URLsForDirectory:NSCachesDirectory
                                         inDomains:NSUserDomainMask] lastObject]
                   URLByAppendingPathComponent:IMAGECACHE_FOLDER
                   isDirectory:YES];
        BOOL isDir = NO;
        if (![_fileManager fileExistsAtPath:[_folder path]
                               isDirectory:&isDir]) {
            [_fileManager createDirectoryAtURL:_folder
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        }
        _url = [_folder URLByAppendingPathComponent:[[url path] lastPathComponent]];
    }
    return self;
}

+ (void)cacheImageData:(NSData *)data forURL:(NSURL *)url
{
    if (!data) return;
    ImageCache *cache = [[ImageCache alloc] initWithURL:url];
    if ([cache.fileManager fileExistsAtPath:[cache.url path]]) {
        [cache.fileManager setAttributes:@{NSFileModificationDate:[NSDate date]}
                            ofItemAtPath:[cache.url path]
                                   error:nil];
    } else {
        [data writeToURL:cache.url atomically:YES];
    }
    [cache cleanupOldFiles];
}

+ (UIImage *)cachedImageForURL:(NSURL *)url
{
    UIImage *image = nil;
    ImageCache *cache = [[ImageCache alloc] initWithURL:url];
    if ([cache.fileManager fileExistsAtPath:[cache.url path]]) {
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:cache.url]];
        [cache.fileManager setAttributes:@{NSFileModificationDate:[NSDate date]}
                            ofItemAtPath:[cache.url path]
                                   error:nil];
    }
    return image;
}

#define IMAGECACHE_MAXSIZE 1024*1024*50
#define IMAGECACHE_MAXNUMBER 20

- (void)cleanupOldFiles
{
    NSDirectoryEnumerator *dirEnumerator =
    [self.fileManager enumeratorAtURL:self.folder
           includingPropertiesForKeys:@[NSURLAttributeModificationDateKey]
                              options:NSDirectoryEnumerationSkipsHiddenFiles
                         errorHandler:nil];
    NSNumber *fileSize;
    NSDate *fileDate;
    NSMutableArray *files = [NSMutableArray array];
    __block NSUInteger dirSize = 0;
    for (NSURL *url in dirEnumerator) {
        [url getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        [url getResourceValue:&fileDate forKey:NSURLAttributeModificationDateKey error:nil];
        dirSize += [fileSize integerValue];
        [files addObject:@{@"url":url, @"size":fileSize, @"date":fileDate}];
    }
    NSArray *sorted = [files sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1[@"date"] compare:obj2[@"date"]];
    }];
    files = [sorted mutableCopy];
    if (dirSize > IMAGECACHE_MAXSIZE) {
        [sorted enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            dirSize -= [obj[@"size"] integerValue];
            NSError *error;
            [self.fileManager removeItemAtURL:obj[@"url"] error:&error];
            [files removeObject:obj];
            *stop = error || (dirSize < IMAGECACHE_MAXSIZE);
        }];
    }
    __block NSUInteger fileCount = [files count];
    if (fileCount > IMAGECACHE_MAXNUMBER) {
        [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            fileCount--;
            NSError *error;
            [self.fileManager removeItemAtURL:obj[@"url"] error:&error];
            *stop = error || (fileCount <= IMAGECACHE_MAXNUMBER);
        }];
    }
}


@end
