//
//  BCHDWFormData.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-12.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <HTMLKit/HTMLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWFormData : NSObject

@property (nonatomic, nullable, strong) NSString* submitUrl;
@property (nonatomic, readonly) NSDictionary* properties;

-(void) addFormProperties:(NSDictionary*) properties;

+(BCHDWFormData*) fromHtml:(HTMLElement*) formElement button:(NSString*) buttonName;

@end

NS_ASSUME_NONNULL_END
