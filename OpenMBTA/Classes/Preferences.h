//
//  Bookmarks.h
//  OpenMBTA
//
//  Created by Daniel Choi on 4/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Preferences : NSObject {
 
}
+ (id)sharedInstance;
- (NSMutableDictionary *)preferences;
- (NSString *)prefsFilePath;

@end
