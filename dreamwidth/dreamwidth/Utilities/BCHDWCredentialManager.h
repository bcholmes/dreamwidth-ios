//
//  BCHDWCredentialManager.h
//  dreamwidth
//
//  Created by BC Holmes on 2021-07-29.
//  Copyright © 2021 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWCredentialManager : NSObject

@property (nonatomic, strong) NSString* apiKey;
@property (nonatomic, readonly) BOOL isApiKeyAvailable;
@property (nonatomic, strong) NSString* userid;
@property (nonatomic, strong) NSString* password;
@property (nonatomic, readonly) BOOL isUseridAndPasswordStoredInKeychain;

+(BCHDWCredentialManager*) sharedInstance;

@end

NS_ASSUME_NONNULL_END
