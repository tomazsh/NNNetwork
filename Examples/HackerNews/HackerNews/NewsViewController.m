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
    
    static NSString *NewsEndpoint = @"http://api.ihackernews.com/page";
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
    NSString *detailString = [NSString stringWithFormat:NSLocalizedString(@"%@ by %@ (%d points)", nil), [newsItem valueForKey:@"postedAgo"], [newsItem valueForKey:@"postedBy"], [[newsItem valueForKey:@"points"] integerValue]];

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
        
        NNReadLaterActivityFailureBlock failureBlock = (^(AFHTTPRequestOperation *operation, NSError *error, NSURL *URL) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Sending to Reading List", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertView show];
        });
        
        NNOAuthCredential *instapaperCredential = [NNOAuthCredential credentialFromKeychainForService:[[NSBundle mainBundle] bundleIdentifier] account:[[NNInstapaperClient sharedClient] name]];
        if (instapaperCredential) {
            NNInstapaperActivity *instapaperActivity = [[NNInstapaperActivity alloc] initWithCredential:instapaperCredential];
            instapaperActivity.failureBlock = failureBlock;
            [applicationActivities addObject:instapaperActivity];
        }
        
        NNOAuthCredential *pocketCredential = [NNOAuthCredential credentialFromKeychainForService:[[NSBundle mainBundle] bundleIdentifier] account:[[NNPocketClient sharedClient] name]];
        if (pocketCredential) {
            NNPocketActivity *pocketActivity = [[NNPocketActivity alloc] initWithCredential:pocketCredential];
            pocketActivity.failureBlock = failureBlock;
            [applicationActivities addObject:pocketActivity];
        }
        
        NNOAuthCredential *readabilityCredential = [NNOAuthCredential credentialFromKeychainForService:[[NSBundle mainBundle] bundleIdentifier] account:[[NNReadabilityClient sharedClient] name]];
        if (readabilityCredential) {
            NNReadabilityActivity *readabilityActivity = [[NNReadabilityActivity alloc] initWithCredential:readabilityCredential];
            readabilityActivity.failureBlock = failureBlock;
            [applicationActivities addObject:readabilityActivity];
        }
        
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

@end
