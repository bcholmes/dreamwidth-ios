//
//  BCHDWPersistenceService.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-06-30.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BCHDWEntry.h"
#import "BCHDWComment.h"

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWPersistenceService : NSObject

-(instancetype) initWithManagedObjectContext:(NSManagedObjectContext*) managedObjectContext;
-(BCHDWEntry*) entryByUrl:(NSString*) url;
-(BCHDWComment*) commentById:(NSString*) commentId author:(NSString*) author;

@end

NS_ASSUME_NONNULL_END
