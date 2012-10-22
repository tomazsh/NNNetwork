//
//  AddAccountViewController.h
//  HackerNews
//
//  Created by Tomaz Nedeljko on 17/10/12.
//  Copyright (c) 2012 Tomaz Nedeljko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddAccountViewController;
@protocol AddAccountViewControllerDelegate <NSObject>

- (void)addAccountViewController:(AddAccountViewController *)controller didObtainCredential:(NNOAuthCredential *)credential;

@end

@interface AddAccountViewController : UITableViewController <UITextFieldDelegate>

@property(weak, nonatomic) id<AddAccountViewControllerDelegate> delegate;
@property(strong, nonatomic) id<NNReadLaterClient> client;
@property(nonatomic) BOOL loggingIn;
@property(strong, readonly, nonatomic) IBOutlet UITextField *usernameField;
@property(strong, readonly, nonatomic) IBOutlet UITextField *passwordField;
@property(strong, readonly, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)login:(id)sender;
- (IBAction)textDidChange:(NSNotification *)notification;

@end
