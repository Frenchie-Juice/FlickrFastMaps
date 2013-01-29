//
//  DataCache.m
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-26.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "DataCache.h"

@interface DataCache()

@property (strong, nonatomic) NSFileManager *fileManager; // File manager
@property (strong, nonatomic) NSURL *cacheURL; // URL for our cache directory
@property (strong, nonatomic) NSArray *fileProperties; // properties used when pre-fetching files
@end


@implementation DataCache

@synthesize cacheURL = _cacheURL;
@synthesize fileManager = _fileManager;
@synthesize fileProperties = _fileProperties;

#pragma mark - Properties

// Get the default file manager
- (NSFileManager *) fileManager
{
    if (!_fileManager)
        _fileManager = [NSFileManager defaultManager];
    return _fileManager;
}

// Returns properties used when pre-fetching files
- (NSArray *) fileProperties
{
    if (!_fileProperties) {
        _fileProperties =
        [NSArray arrayWithObjects: NSURLNameKey, NSURLFileSizeKey, NSURLCreationDateKey, nil];
    }
    return _fileProperties;
}

// Sets the cache URL
- (void)setCacheURL:(NSURL *)cacheURL
{
    if (cacheURL == _cacheURL) return;
    _cacheURL = cacheURL;
    
    BOOL isDir = NO;
    if (![self.fileManager fileExistsAtPath:[_cacheURL path] isDirectory:&isDir] || !isDir)
        [self.fileManager createDirectoryAtURL:_cacheURL
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
}

#pragma mark - Helper Methods

// Returns the URL for our cache directory
- (NSURL *) cacheURLForFolder:(NSString *)folder
{
    // Retrieve a list of URL for our Cache directory
    NSArray *cachesArray = [[self fileManager] URLsForDirectory:NSCachesDirectory
                                                          inDomains:NSUserDomainMask];
    // Create a new directory for our cache
    self.cacheURL = [[cachesArray lastObject] URLByAppendingPathComponent:folder isDirectory:YES];
    
    return self.cacheURL;
}

- (void)tidyUpCache
{
    // Get an array of all the files in the cache directory
    NSArray *cachedURLs = [self.fileManager contentsOfDirectoryAtURL:self.cacheURL
                                           includingPropertiesForKeys:self.fileProperties
                                                              options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                error:nil];
    
    int cacheSize = 0;
    NSMutableArray *files = [NSMutableArray array];
    
    // Go through the files in the cache and calculate the total size
    for (NSURL *url in cachedURLs) {
        NSDictionary *fileProperties = [url resourceValuesForKeys:self.fileProperties error:nil];
        
        cacheSize += [[fileProperties valueForKey:NSURLFileSizeKey] intValue];
        
        [files addObject:fileProperties];
    }
    
    // If the cache is full, remove older files
    if (cacheSize > MAX_CACHE_SIZE) {
        // Sort the files by creation date
        NSMutableArray *sortedFiles = [[files sortedArrayUsingComparator:^NSComparisonResult(id fileProps1, id fileProps2) {
            return [[fileProps1 valueForKey:NSURLCreationDateKey] compare:[fileProps2 valueForKey:NSURLCreationDateKey]];
        }] mutableCopy];
        
        // Remove the oldest files until we have enough space
        while (cacheSize > TRIM_CACHE_SIZE) {
            cacheSize -= [[sortedFiles[0] valueForKey:NSURLFileSizeKey] intValue];
            NSURL *oldestFileURL = [self.cacheURL URLByAppendingPathComponent:[sortedFiles[0] valueForKey:NSURLNameKey]];
            [self.fileManager removeItemAtURL:oldestFileURL error:nil];
            [sortedFiles removeObjectAtIndex:0];
        }
    }
}

#pragma mark - DataCache Public Interface

// Stores the file in cache
- (void)storeData: (NSData *)data intoCacheFile: (NSString *)cacheFile
{
    NSURL *url = [self.cacheURL URLByAppendingPathComponent:cacheFile];
    if ([self.fileManager fileExistsAtPath:[url path]]) return;
    
    // Write the data to the cache if it's not there
    [data writeToURL: url atomically:true];
}

// Reload the data from a file in cache
- (NSData *)reloadDataFromCacheFile: (NSString *)cacheFile
{
    NSURL *url = [self.cacheURL URLByAppendingPathComponent:cacheFile];
    if ([self.fileManager fileExistsAtPath:[url path]]) {
        // Return the content of the file from the cache
        return [NSData dataWithContentsOfURL:url];
    }
    return nil;
}

// Get a cache manager
+ (DataCache *)cacheForFolder:(NSString *)folder
{
    DataCache *cache = [[DataCache alloc] init];
    // Initialize the folder for this cache
    [cache cacheURLForFolder:folder];
    
    // To optimize performance, the cache size is checked when the application is launched
    dispatch_queue_t cacheQueue = dispatch_queue_create("tidyUpCache", NULL);
    dispatch_async(cacheQueue, ^{ [cache tidyUpCache]; });

    return cache;
}

@end
