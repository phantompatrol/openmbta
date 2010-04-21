//
//  Bookmarks.m
//  OpenMBTA
//
//  Created by Daniel Choi on 4/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Preferences.h"


@implementation Preferences

- (id)init {
    self = [super init];
    if (nil != self) { }
    return self;
}

+ (id)sharedInstance {
    static Preferences *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[[self class] alloc] init];
    }
    return sharedInstance;
}

- (NSMutableDictionary *)preferences {
    NSMutableDictionary *prefs;
    if ([[NSFileManager defaultManager] fileExistsAtPath: [self prefsFilePath]]) { 
        prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: [self prefsFilePath]]; 
    } else {
        prefs = [[NSMutableDictionary alloc] initWithCapacity: 3];
        [prefs setObject:[NSMutableArray array] forKey:@"bookmarks"];
    }
    [prefs autorelease];
    return prefs;
};

- (NSString *) prefsFilePath { 
    NSString *cacheDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]; 
    NSString *prefsFilePath = [cacheDirectory stringByAppendingPathComponent: @"OpenMBTAPrefs.plist"]; 
    return prefsFilePath;
} 


- (void)addBookmark:(NSDictionary *)bookmark {
    NSMutableDictionary *prefs = [self preferences];
    NSArray *bookmarks = [prefs objectForKey:@"bookmarks"];
    [bookmarks addObject:bookmark];

    if (![prefs writeToFile:[self prefsFilePath] atomically:YES]) {
         NSLog(@"VRM failed to save preferences to file!");
    }
    //NSLog(@"added bookmark. new prefs: %@", [self preferences]);
}

- (void)removeBookmark:(NSDictionary *)bookmark {
    NSMutableDictionary *prefs = [self preferences];
    NSArray *bookmarks = [prefs objectForKey:@"bookmarks"];
    for (NSDictionary *saved in bookmarks) {
        if ([[saved objectForKey:@"headsign"] isEqualToString: [bookmark objectForKey:@"headsign"]] &&
            [[saved objectForKey:@"routeShortName"] isEqualToString: [bookmark objectForKey:@"routeShortName"]] &&
            [[saved objectForKey:@"transportType"] isEqualToString: [bookmark objectForKey:@"transportType"]])  {
             [bookmarks removeObject:saved];
            if (![prefs writeToFile:[self prefsFilePath] atomically:YES]) {
                 NSLog(@"VRM failed to save preferences to file!");
            }

    //        NSLog(@"removed bookmark. new prefs: %@", [self preferences]);
            return;
        }
    }
}

- (BOOL)isBookmarked:(NSDictionary *)bookmark {
    NSMutableDictionary *prefs = [self preferences];
    NSArray *bookmarks = [prefs objectForKey:@"bookmarks"];
    for (NSDictionary *saved in bookmarks) {
        if ([[saved objectForKey:@"headsign"] isEqualToString: [bookmark objectForKey:@"headsign"]] &&
            [[saved objectForKey:@"routeShortName"] isEqualToString: [bookmark objectForKey:@"routeShortName"]] &&
            [[saved objectForKey:@"transportType"] isEqualToString: [bookmark objectForKey:@"transportType"]])  {
            return true;
        }
    }

    return false;
}

@end
