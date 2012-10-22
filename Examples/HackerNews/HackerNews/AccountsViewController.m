//
//  AccountsViewController.m
//  NNNetworkExample
//
//  Created by Tomaz Nedeljko on 16/10/12.
//  Copyright (c) 2012 Tomaz Nedeljko. All rights reserved.
//

#import "AccountsViewController.h"

@implementation AccountsViewController

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _readLaterClients = @[[NNInstapaperClient sharedClient], [NNPocketClient sharedClient], [NNReadabilityClient sharedClient]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddAccountSegue"]) {
        AddAccountViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath) {
            id<NNReadLaterClient> client = [self.readLaterClients objectAtIndex:indexPath.row];
            controller.client = client;
        }
    }
}

#pragma mark -
#pragma mark Public Methods

- (IBAction)done:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(accountsViewControllerDidFinish:)]) {
        [self.delegate accountsViewControllerDidFinish:self];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.readLaterClients count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<NNReadLaterClient> client = [self.readLaterClients objectAtIndex:indexPath.row];
    NNOAuthCredential *credential = [NNOAuthCredential credentialFromKeychainForService:[[NSBundle mainBundle] bundleIdentifier] account:client.name];
    NSString *accountName = [[credential userInfo] valueForKey:@"AccountName"];
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = client.name;
    cell.detailTextLabel.text = accountName;
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<NNReadLaterClient> client = [self.readLaterClients objectAtIndex:indexPath.row];
    NNOAuthCredential *credential = [NNOAuthCredential credentialFromKeychainForService:[[NSBundle mainBundle] bundleIdentifier] account:client.name];

    if (credential) {        
        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"You already have an account linked for %@. Do you want to unlink this account and add a new one?", nil), client.name];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Unlink", nil), NSLocalizedString(@"Unlink and Add New", nil), nil];
        [actionSheet showInView:self.view];
    } else {
        [self performSegueWithIdentifier:@"AddAccountSegue" sender:self];
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (!indexPath) {
        return;
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    id<NNReadLaterClient> client = [self.readLaterClients objectAtIndex:indexPath.row];
    NNOAuthCredential *credential = [NNOAuthCredential credentialFromKeychainForService:[[NSBundle mainBundle] bundleIdentifier] account:client.name];
    
    if (buttonIndex == 0) {
        [credential removeFromKeychainForService:[[NSBundle mainBundle] bundleIdentifier] account:client.name];
        cell.detailTextLabel.text = nil;
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    } else if (buttonIndex == 1) {
        [credential removeFromKeychainForService:[[NSBundle mainBundle] bundleIdentifier] account:client.name];
        cell.detailTextLabel.text = nil;
        [self performSegueWithIdentifier:@"AddAccountSegue" sender:self];
    } else {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    }
}

#pragma mark -
#pragma mark AddAccountViewControllerDelegate

- (void)addAccountViewController:(AddAccountViewController *)controller didObtainCredential:(NNOAuthCredential *)credential
{
    NNOAuthCredential *newCredential = [NNOAuthCredential credentialWithAccessToken:credential.accessToken accessSecret:credential.accessSecret userInfo:@{ @"AccountName" : controller.usernameField.text }];
    [newCredential saveToKeychainForService:[[NSBundle mainBundle] bundleIdentifier] account:controller.client.name];
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
