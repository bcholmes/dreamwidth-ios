//
//  BCHDWLoginViewController.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-06-08.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWLoginViewController.h"

#import <AFNetworking/AFNetworking.h>
#import <AudioToolbox/AudioServices.h>
#import <MaterialComponents/MaterialSnackbar.h>
#import <MaterialComponents/MaterialTextFields.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import <1PasswordExtension/OnePasswordExtension.h>

#import "BCHDWAppDelegate.h"
#import "BCHDWTheme.h"

@interface BCHDWLoginViewController ()

@property (nonatomic, weak) IBOutlet MDCTextField* usernameField;
@property (nonatomic, weak) IBOutlet MDCTextField* passwordField;

@property (nonatomic, nullable, strong) MDCTextInputControllerUnderline* usernameFieldController;
@property (nonatomic, nullable, strong) MDCTextInputControllerUnderline* passwordFieldController;

@property (nonatomic, nullable, weak) IBOutlet UIScrollView* scrollView;
@property (nonatomic, nullable, weak) IBOutlet UIButton* onePasswordButton;

@end

@implementation BCHDWLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [BCHDWTheme instance].loginScreenColor;
    
    [self.onePasswordButton setHidden:![[OnePasswordExtension sharedExtension] isAppExtensionAvailable]];
    
    [self.usernameField addTarget:self action:@selector(login:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordField addTarget:self action:@selector(login:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    self.passwordFieldController = [[MDCTextInputControllerUnderline alloc] initWithTextInput:self.passwordField];
    [[BCHDWTheme instance] applyTheme:self.passwordFieldController];
    self.usernameFieldController = [[MDCTextInputControllerUnderline alloc] initWithTextInput:self.usernameField];
    [[BCHDWTheme instance] applyTheme:self.usernameFieldController];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(IBAction) login:(id)sender {
    NSString* username = self.usernameField.text;
    NSString* password = self.passwordField.text;
    
    if (self.usernameField.text.length > 0 && self.passwordField.text.length > 0) {
        BCHDWDreamwidthService* service = [BCHDWAppDelegate instance].dreamwidthService;
        [SVProgressHUD show];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [service loginWithUser:username password:password andCompletion:^(NSError* error, BCHDWUser* user) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (error != nil) {
                        NSUInteger statusCode = [[error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
                        MDCSnackbarMessage* message = [[MDCSnackbarMessage alloc] init];
                        if (statusCode != 401) {
                            message.text = @"There might be a problem logging in to the server. Try again later?";
                        } else {
                            message.text = @"That login did not go the way we wanted it to. Double-check your userid/password.";
                        }
                        [MDCSnackbarManager showMessage:message];
                    } else {
                        NSLog(@"Logged in as user %@", user.name);
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                });
            }];
        });
    } else {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (IBAction) findLoginFrom1Password:(id)sender {
    [[OnePasswordExtension sharedExtension] findLoginForURLString:@"https://www.dreamwidth.org" forViewController:self sender:sender completion:^(NSDictionary *loginDictionary, NSError *error) {
        if (loginDictionary.count == 0) {
            if (error.code != AppExtensionErrorCodeCancelledByUser) {
                NSLog(@"Error invoking 1Password App Extension for find login: %@", error);
            }
            return;
        }
        
        self.usernameField.text = loginDictionary[AppExtensionUsernameKey];
        self.passwordField.text = loginDictionary[AppExtensionPasswordKey];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
