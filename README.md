NNNetwork
=========

NNNetwork is a collection of classes that power networking in [Postr](http://postrapp.com). It is built atop [AFNetworking](http://github.com/afnetworking/AFNetworking) and it provides categories for networking, OAuth 1.0 utilities and read later integration classes.

Interacting with OAuth 1.0 Services
-----------------------------------

`NNOAuth` class provides a single point to generate an OAuth 1.0 HTTP authorization header. You can also use a `NSURLRequest(NNNetwork)` category to copy a request and sign it or `NSMutableURLRequest(NNNetwork)` category to sign an existing request. NNNetwork features a `NNOAuth1Client` which extends `AFHTTPClient` to enable interaction with an OAuth service. It defines custom methods for making signed requests from relative paths of a base URL. You can also define your own OAuth clients (eg. for OAuth 2.0) by sublassing `NNOAuthClient` and overriding `signRequest:withParameters:credential:`. You use `NNOAuthClient` subclasses just as you would use an `AFHTTPClient` subclass:

``` objective-c
SomeOAuthClientSublass *client = [SomeOAuthClientSublass sharedClient];
client.clientIdentifier = @"your-app-identifier";
client.clientSecret = @"your-app-secret";

NNOAuthCredential *credential = [NNOAuthCredential credentialWithAccessToken:@"user-token" accessSecret:@"user-secret"];

[client signedGetPath:@"some-endpoint" parameters:nil credential:credential success:^(AFHTTPRequestOperation *operation, id responseObject){
	// Handle success.
} failure:^(AFHTTPRequestOperation *operation, NSError *error){
	// Handle failure.
}];
```

Interacting with Read Later Services
------------------------------------

NNNetwork defines clients for Instapaper, Pocket and Readability, that currently enable you to send an URL to a reading list. These classes extend `NNOAuth1Client` and conform to `NNReadLaterClient` protocol for consistency. NNNetwork supports Instapaper, Pocket and Readability. It also provides counterpart `UIActivity` subclasses. They come along with image resources for `UIActivityController`. Here's how you would present an activity view controller with Instapaper support from a view controller in iOS 6:

``` objective-c
[[NNInstapaperClient sharedClient] setClientIdentifier:@"your-instapaper-app-identifier"];
[[NNInstapaperClient sharedClient] setClientSecret:@"your-instapaper-app-secret"];
NNOAuthCredential *credential = [NNOAuthCredential credentialWithAccessToken:@"user-token" accessSecret:@"user-secret"];

NSURL *readLaterURL = [NSURL URLWithString:@"http://github.com/tomazsh/NNNetwork"];
NNInstapaperActivity *activity = [[NNInstapaperActivity alloc] initWithCredential:credential];
UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[readLaterURL] applicationActivities:@[activity]];
[self presentViewController:controller animated:YES completion:nil];
```

Hacker News Demo App
--------------------

NNNetwork comes with a demo app that demostrates how you would use read later clients and activites to provide read later support in a simple app that fetches articles from Y Combinator's Hacker News.

Documentation
-------------

Detailed documentation is available [here](http://tomazsh.github.com/NNNetwork/).

Requirements
------------

NNNetwork requires iOS 5.0 and uses ARC. You can use all categories and sign OAuth requests. Read later activites require iOS 6.0. For OAuth client support and reading list integration NNNetwork requires [AFNetworking](http://github.com/afnetworking/AFNetworking). Making OAuth credentials keychain friendly requires [SSKeychain](http://github.com/soffes/sskeychain).

Known Issues
------------

There is currently no support for OAuth 1.0 RSA-SHA1 signing algorithm. There is also no OAuth 2.0 support whatsoever.

License
-------

NNNetwork is available under the MIT license. See the LICENSE file for more info.