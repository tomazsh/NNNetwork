//
//  NewsViewController.m
//  NNNetworkExample
//
//  Created by Tomaz Nedeljko on 16/10/12.
//  Copyright (c) 2012 Tomaz Nedeljko. All rights reserved.
//

#import "NewsViewController.h"
#import "AFJSONRequestOperation.h"
#import "NewsItemCell.h"

@interface NewsViewController ()

@property(strong, nonatomic) id<NNReadLaterClient> unlinkedClient;

@end

@implementation NewsViewController

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    [self refresh:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AccountsSegue"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AccountsViewController *controller = [[navigationController viewControllers] objectAtIndex:0];
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"AddAccountSegue"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AddAccountViewController *controller = [[navigationController viewControllers] objectAtIndex:0];
        controller.client = self.unlinkedClient;
        controller.delegate = self;
    }
}

#pragma mark -
#pragma mark Public Methods

- (IBAction)refresh:(id)sender
{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        [_operationQueue setMaxConcurrentOperationCount:4];
        
        UIBackgroundTaskIdentifier identifier = UIBackgroundTaskInvalid;
        identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [_operationQueue cancelAllOperations];
            [[UIApplication sharedApplication] endBackgroundTask:identifier];
        }];
    }
    
    static NSString *NewsEndpoint = @"http://hndroidapi.appspot.com/news/format/json/page/?appid=&callback=";
    NSURL *requestURL = [NSURL URLWithString:NewsEndpoint];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];

    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        _newsItems = [responseObject valueForKeyPath:@"items"];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Loading News", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertView show];
        [self.refreshControl endRefreshing];
    }];
    [self.operationQueue addOperation:operation];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.newsItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    NewsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    id newsItem = [self.newsItems objectAtIndex:indexPath.row];
    NSString *detailString = [NSString stringWithFormat:NSLocalizedString(@"%@ by %@ (%@)", nil), [newsItem valueForKey:@"time"], [newsItem valueForKey:@"user"], [newsItem valueForKey:@"score"]];

    cell.titleLabel.text = [newsItem valueForKey:@"title"];
    cell.linkLabel.text = [newsItem valueForKey:@"url"];
    cell.detailLabel.text = detailString;
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    id newsItem = [self.newsItems objectAtIndex:indexPath.row];
    NSURL *newsItemURL = [NSURL URLWithString:[newsItem valueForKey:@"url"]];
    if (newsItemURL) {
        NSMutableArray *applicationActivities = [NSMutableArray arrayWithCapacity:3];

        NNOAuthCredential *instapaperCredential = [NNOAuthCredential credentialFromKeychainForService:[[NSBundle mainBundle] bundleIdentifier] account:[[NNInstapaperClient sharedClient] name]];
        NNInstapaperActivity *instapaperActivity = [[NNInstapaperActivity alloc] initWithCredential:instapaperCredential];
        instapaperActivity.delegate = self;
        [applicationActivities addObject:instapaperActivity];
        
        NNOAuthCredential *pocketCredential = [NNOAuthCredential credentialFromKeychainForService:[[NSBundle mainBundle] bundleIdentifier] account:[[NNPocketClient sharedClient] name]];
        NNPocketActivity *pocketActivity = [[NNPocketActivity alloc] initWithCredential:pocketCredential];
        pocketActivity.delegate = self;
        [applicationActivities addObject:pocketActivity];
        
        NNOAuthCredential *readabilityCredential = [NNOAuthCredential credentialFromKeychainForService:[[NSBundle mainBundle] bundleIdentifier] account:[[NNReadabilityClient sharedClient] name]];
        NNReadabilityActivity *readabilityActivity = [[NNReadabilityActivity alloc] initWithCredential:readabilityCredential];
        readabilityActivity.delegate = self;
        [applicationActivities addObject:readabilityActivity];
        
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[newsItemURL] applicationActivities:applicationActivities];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark AccountsViewControllerDelegate

- (void)accountsViewControllerDidFinish:(AccountsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark NNReadLaterActivityDelegate

- (void)readLaterActivityNeedsCredential:(NNReadLaterActivity *)activity
{
    id<NNReadLaterClient> client = activity.client;
    if ([client isKindOfClass:[NNPocketClient class]]) {
        NNPocketClient *pocketClient = (NNPocketClient *)client;
        [pocketClient authorizeWithSuccess:^(AFHTTPRequestOperation *operation, NSString *username, NNOAuth2Credential *credential) {
            NNOAuth2Credential *newCredential = [[NNOAuth2Credential alloc] initWithAccessToken:credential.accessToken userInfo:@{ @"AccountName" : username }];
            [newCredential saveToKeychainForService:[[NSBundle mainBundle] bundleIdentifier] account:pocketClient.name];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Logging In", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertView show];
        }];
    }
    else {
        self.unlinkedClient = client;
        
        // This is needed in order to avoid a controller presentation warning.
        int64_t delay = 750.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_MSEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSegueWithIdentifier:@"AddAccountSegue" sender:nil];
        });
    }
}

- (void)readLaterActivity:(NNReadLaterActivity *)activity didFinishWithURL:(NSURL *)url operation:(AFHTTPRequestOperation *)operation error:(NSError *)error
{
    if (error) {
        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Error Sending to %@", nil), activity.client.name];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark -
#pragma mark AddAccountViewControllerDelegate

- (void)addAccountViewController:(AddAccountViewController *)controller didObtainCredential:(NNOAuth1Credential *)credential
{
    NNOAuth1Credential *newCredential = [NNOAuth1Credential credentialWithAccessToken:credential.accessToken accessSecret:credential.accessSecret userInfo:@{ @"AccountName" : controller.usernameField.text }];
    [newCredential saveToKeychainForService:[[NSBundle mainBundle] bundleIdentifier] account:controller.client.name];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addAccountViewControllerDidCancel:(AddAccountViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
