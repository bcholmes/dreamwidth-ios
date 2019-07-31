//
//  BCHDWEntrySummarizer.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-30.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWSummaryExtract : NSObject

@property (nonatomic, nullable, strong) NSMutableString* summaryText1;
@property (nonatomic, nullable, strong) NSMutableString* summaryText2;
@property (nonatomic, nullable, strong) NSString* summaryImageUrl;
@property (nonatomic, nullable, readonly) NSMutableString* currentText;
@property (nonatomic, readonly) BOOL isMaxLength;

@end

@interface BCHDWEntrySummarizer : NSObject

@end

NS_ASSUME_NONNULL_END
