//
//  BCHDWComposeReplyViewController.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-08.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWComposeReplyViewController.h"

#import <MaterialComponents/MaterialSnackbar.h>
#import <MaterialComponents/MaterialTextFields.h>
#import <MaterialComponents/MaterialBottomSheet.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#import "BCHDWAppDelegate.h"
#import "BCHDWAvatarPickerViewController.h"

@interface BCHDWComposeReplyViewController ()

@property (nonatomic, weak) IBOutlet UIImageView* avatarImageView;
@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;

@property (nonatomic, weak) IBOutlet MDCTextField* subjectTextField;
@property (nonatomic, weak) IBOutlet MDCMultilineTextField* commentTextField;

@property (nonatomic, strong) BCHDWAvatar* selectedAvatar;

@end

@implementation BCHDWComposeReplyViewController

- (void) assignAvatarImage {
    if (self.selectedAvatar != nil) {
        [self.avatarImageView setImageWithURL:[NSURL URLWithString:self.selectedAvatar.url] placeholderImage:[UIImage imageNamed:@"user"]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    BCHDWDreamwidthService* service = [BCHDWAppDelegate instance].dreamwidthService;
    self.selectedAvatar = service.currentUser.defaultAvatar;
    [self assignAvatarImage];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseAvatar)];
    singleTap.numberOfTapsRequired = 1;
    [self.avatarImageView setUserInteractionEnabled:YES];
    [self.avatarImageView addGestureRecognizer:singleTap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification*) notification {
    
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

-(void)keyboardWillHide {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
}

-(void) chooseAvatar {
    [self.view endEditing:YES];
    NSLog(@"avatar time!");
    
    BCHDWAvatarPickerViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"avatarPickerView"];
    viewController.onSelection= ^(BCHDWAvatar* avatar) {
        self.selectedAvatar = avatar;
        [self assignAvatarImage];
    };
    
    MDCBottomSheetController *bottomSheet = [[MDCBottomSheetController alloc] initWithContentViewController:viewController];
    [self presentViewController:bottomSheet animated:true completion:nil];

}

-(IBAction) postComment:(id)sender {
    if (self.commentTextField.text.length > 0) {
        BCHDWDreamwidthService* service = [BCHDWAppDelegate instance].dreamwidthService;
        BCHDWCommentEntryData* data = [BCHDWCommentEntryData new];
        data.subject = self.subjectTextField.text;
        data.commentText = self.commentTextField.text;
        data.avatar = self.selectedAvatar;
        
        [SVProgressHUD show];
        [service postComment:data entry:self.entry parentComment:self.comment callback:^(NSError* error) {
            [SVProgressHUD dismiss];
            
            if (error) {
                [[MDCSnackbarManager new] showMessage:[MDCSnackbarMessage messageWithText:@"Ooops. We ran into a problem trying to post your comment."]];
            } else {
                [self close:nil];
            }
            
        }];
    } else {
        [[MDCSnackbarManager new]  showMessage:[MDCSnackbarMessage messageWithText:@"C'mon. You need to type something"]];
    }
}

-(IBAction) close:(id) button {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
