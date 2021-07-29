//
//  BCHDWCredentialManager.m
//  dreamwidth
//
//  Created by BC Holmes on 2021-07-29.
//  Copyright © 2021 Ayizan Studios. All rights reserved.
//

#import "BCHDWCredentialManager.h"

#import <UYLPasswordManager/UYLPasswordManager.h>

@implementation BCHDWCredentialManager

+(BCHDWCredentialManager*) sharedInstance {
    static BCHDWCredentialManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(BOOL) isApiKeyAvailable {
    return self.apiKey != nil;
}

-(NSString*) apiKey {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:@"apiKey"];
}

-(void) setApiKey:(NSString*) apiKey {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:apiKey forKey:@"apiKey"];
    [userDefaults synchronize];
}

-(NSString*) password {
    UYLPasswordManager* manager = [UYLPasswordManager sharedInstance];
    return [manager keyForIdentifier:@"password"];
}

-(void) setPassword:(NSString*) password {
    UYLPasswordManager* manager = [UYLPasswordManager sharedInstance];
    [manager setValue:password forKey:@"password"];
}

-(NSString*) userid {
    UYLPasswordManager* manager = [UYLPasswordManager sharedInstance];
    return [manager keyForIdentifier:@"userid"];
}

-(void) setUserid:(NSString*) userid {
    UYLPasswordManager* manager = [UYLPasswordManager sharedInstance];
    [manager setValue:userid forKey:@"userid"];
}

-(BOOL) isUseridAndPasswordStoredInKeychain {
    UYLPasswordManager* manager = [UYLPasswordManager sharedInstance];
    NSString* userid = [manager keyForIdentifier:@"userid"];
    NSString* password = [manager keyForIdentifier:@"password"];
    return userid != nil && password != nil;
}

@end
