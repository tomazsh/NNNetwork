//
//  AppDelegate.m
//  NNNetworkExample
//
//  Created by Tomaz Nedeljko on 16/10/12.
//  Copyright (c) 2012 Tomaz Nedeljko. All rights reserved.
//

#import "AppDelegate.h"

NSString * const kInstapaperAPIClientIdentifier = @"";
NSString * const kInstapaperAPIClientSecret = @"";
NSString * const kPocketAPIClientIdentifier = @"";
NSString * const kReadabilityAPIClientIdentifier = @"";
NSString * const kReadabilityAPIClientSecret = @"";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set your client identifiers and secrets if you want to test read later services.
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[NNInstapaperClient sharedClient] setClientIdentifier:kInstapaperAPIClientIdentifier];
    [[NNInstapaperClient sharedClient] setClientSecret:kInstapaperAPIClientSecret];
    [[NNPocketClient sharedClient] setClientIdentifier:kPocketAPIClientIdentifier];
    [[NNPocketClient sharedClient] setScheme:@"pocketapp-hacker-news"];
    [[NNReadabilityClient sharedClient] setClientIdentifier:kReadabilityAPIClientIdentifier];
    [[NNReadabilityClient sharedClient] setClientSecret:kReadabilityAPIClientSecret];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[NNPocketClient sharedClient] handleRedirectionURL:url]) {
        return YES;
    } else {
        return NO;
    }
}

@end
