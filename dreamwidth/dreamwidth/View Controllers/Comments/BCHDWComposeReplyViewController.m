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
#import <SVProgressHUD/SVProgressHUD.h>

#import "BCHDWAppDelegate.h"

@interface BCHDWComposeReplyViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;

@property (nonatomic, weak) IBOutlet MDCTextField* subjectTextField;
@property (nonatomic, weak) IBOutlet MDCMultilineTextField* commentTextField;

@end

@implementation BCHDWComposeReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

-(IBAction) postComment:(id)sender {
    if (self.commentTextField.text.length > 0) {
        BCHDWDreamwidthService* service = [BCHDWAppDelegate instance].dreamwidthService;
        BCHDWCommentEntryData* data = [BCHDWCommentEntryData new];
        data.subject = self.subjectTextField.text;
        data.commentText = self.commentTextField.text;
        
        [SVProgressHUD show];
        [service postComment:data entry:self.entry parentComment:self.comment callback:^(NSError* error) {
            [SVProgressHUD dismiss];
            
            if (error) {
                [MDCSnackbarManager showMessage:[MDCSnackbarMessage messageWithText:@"Ooops. We ran into a problem trying to post your comment."]];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }];
    } else {
        [MDCSnackbarManager showMessage:[MDCSnackbarMessage messageWithText:@"C'mon. You need to type something"]];
    }
}
@end
