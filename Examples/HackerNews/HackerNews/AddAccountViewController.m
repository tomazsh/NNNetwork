//
//  AddAccountViewController.m
//  HackerNews
//
//  Created by Tomaz Nedeljko on 17/10/12.
//  Copyright (c) 2012 Tomaz Nedeljko. All rights reserved.
//

#import "AddAccountViewController.h"

@implementation AddAccountViewController

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.client.name;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:self.usernameField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:self.passwordField];
    [self textDidChange:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.usernameField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.usernameField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.passwordField];
}

#pragma mark -
#pragma mark Properties

- (void)setLoggingIn:(BOOL)loggingIn
{
    _loggingIn = loggingIn;
    self.navigationItem.leftBarButtonItem.enabled = !_loggingIn;
    if (_loggingIn) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
}

#pragma mark -
#pragma mark Public Methods

- (IBAction)login:(id)sender
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    self.loggingIn = YES;
    
    [self.client credentialWithUsername:self.usernameField.text password:self.passwordField.text success:^(AFHTTPRequestOperation *operation, NNOAuthCredential *credential) {
        if ([self.delegate respondsToSelector:@selector(addAccountViewController:didObtainCredential:)]) {
            [self.delegate addAccountViewController:self didObtainCredential:credential];
        }
        self.loggingIn = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Logging In", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertView show];
        self.loggingIn = NO;
    }];
}

- (IBAction)cancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addAccountViewControllerDidCancel:)]) {
        [self.delegate addAccountViewControllerDidCancel:self];
    }
}

- (IBAction)textDidChange:(NSNotification *)notification
{
    if ([self.usernameField.text length] && [self.passwordField.text length]) {
        self.loginButton.enabled = YES;
    } else {
        self.loginButton.enabled = NO;
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameField) {
        [self.passwordField becomeFirstResponder];
        return NO;
    } else if (![self.usernameField.text length]) {
        [self.usernameField becomeFirstResponder];
        return NO;
    } else {
        [self login:textField];
    }
    return YES;
}

@end
