//
//  BCHDWHTMLHelper.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-06.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWBlock : NSObject

@property (nonatomic, readonly) BOOL empty;

@end

@interface BCHDWTextBlock : BCHDWBlock

@property (nonatomic, readonly) NSAttributedString* text;

@end

@interface BCHDWImageBlock : BCHDWBlock

@property (nonatomic, strong) NSString* imageUrl;
@property (nonatomic, strong) NSString* link;

@end


@interface BCHDWHTMLHelper : NSObject

-(NSArray<BCHDWBlock*>*) parseHtmlIntoAttributedStrings:(NSString*) html;

@end

NS_ASSUME_NONNULL_END
