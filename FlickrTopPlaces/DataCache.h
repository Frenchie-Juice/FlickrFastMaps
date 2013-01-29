//
//  DataCache.h
//  FlickrTopPlaces
//
//  Created by Fred Gagnepain on 2013-01-26.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataCache : NSObject

#define MAX_CACHE_SIZE 10485760 //10MB
#define TRIM_CACHE_SIZE 5242880 //5MB

// Store data to cache
- (void)storeData: (NSData *)data intoCacheFile: (NSString *)cacheFile;

// Reload data from cache
- (NSData *)reloadDataFromCacheFile: (NSString *)cacheFile;

// Creation method
+ (DataCache *)cacheForFolder:(NSString *)folder;
@end
