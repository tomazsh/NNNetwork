//
//  AppDelegate.m
//  NNNetworkExample
//
//  Created by Tomaz Nedeljko on 16/10/12.
//  Copyright (c) 2012 Tomaz Nedeljko. All rights reserved.
//

#import "AppDelegate.h"

<<<<<<< HEAD
=======
NSString * const kInstapaperAPIClientIdentifier = @"";
NSString * const kInstapaperAPIClientSecret = @"";
NSString * const kPocketAPIClientIdentifier = @"";
NSString * const kReadabilityAPIClientIdentifier = @"";
NSString * const kReadabilityAPIClientSecret = @"";

>>>>>>> 75119ff... Added support for authorization with OAuth 2.0 services.
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set your client identifiers and secrets if you want to test read later services.
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
<<<<<<< HEAD
    [[NNInstapaperClient sharedClient] setClientIdentifier:@""];
    [[NNInstapaperClient sharedClient] setClientSecret:@""];
    [[NNPocketClient sharedClient] setAPIKey:@""];
    [[NNReadabilityClient sharedClient] setClientIdentifier:@""];
    [[NNReadabilityClient sharedClient] setClientSecret:@""];
=======
    [[NNInstapaperClient sharedClient] setClientIdentifier:kInstapaperAPIClientIdentifier];
    [[NNInstapaperClient sharedClient] setClientSecret:kInstapaperAPIClientSecret];
    [[NNPocketClient sharedClient] setClientIdentifier:kPocketAPIClientIdentifier];
    [[NNPocketClient sharedClient] setScheme:@"pocketapp-hacker-news"];
    [[NNReadabilityClient sharedClient] setClientIdentifier:kReadabilityAPIClientIdentifier];
    [[NNReadabilityClient sharedClient] setClientSecret:kReadabilityAPIClientSecret];
>>>>>>> 75119ff... Added support for authorization with OAuth 2.0 services.
    return YES;
}

@end
