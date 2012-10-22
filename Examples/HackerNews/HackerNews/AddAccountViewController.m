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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:self.usernameField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:self.passwordField];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
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

- (IBAction)textDidChange:(NSNotification *)notification
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    if ([self.usernameField.text length] && [self.passwordField.text length]) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.enabled = YES;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.enabled = NO;
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 1) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Login with %@", nil), self.client.name];
    }
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 1 && [self.usernameField.text length] && [self.passwordField.text length]) {
        [self login:self];
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
