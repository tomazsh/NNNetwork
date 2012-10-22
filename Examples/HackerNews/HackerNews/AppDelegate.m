//
//  AppDelegate.m
//  NNNetworkExample
//
//  Created by Tomaz Nedeljko on 16/10/12.
//  Copyright (c) 2012 Tomaz Nedeljko. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set your client identifiers and secrets if you want to test read later services.
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[NNInstapaperClient sharedClient] setClientIdentifier:@""];
    [[NNInstapaperClient sharedClient] setClientSecret:@""];
    [[NNPocketClient sharedClient] setAPIKey:@""];
    [[NNReadabilityClient sharedClient] setClientIdentifier:@""];
    [[NNReadabilityClient sharedClient] setClientSecret:@""];
    return YES;
}

@end
