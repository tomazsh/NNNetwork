//
//  NNPocketClient.h
//  NNNetwork
//
//  Copyright (c) 2012 Tomaz Nedeljko (http://nedeljko.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "NNOAuth2Client.h"
#import "NNReadLaterClient.h"

@class NNOAuth2Credential;

/**
 `NNPocketClient` class provides a way of interacting with [Pocket](http://getpocket.com). It defines methods to access the shared client instance and to add URLs to a reading list. This class fully conforms to `NNReadLaterClient` protocol.
 */
@interface NNPocketClient : NNOAuth2Client <NNReadLaterClient>

@property(copy, nonatomic) NSString *scheme;

///------------------------
/// @name Authorizing Users
///------------------------

/**
 Creates an `AFHTTPRequestOperation` with a `POST` request, and enqueues it to the OAuth client’s operation queue. On completion it parses the response and passes a temporary credential to the `success` block parameter. For client to be able to parse the response successfully, `path` should be a valid temporary credential endpoint. To learn more about this, see [The OAuth 1.0 Protocol](http://tools.ietf.org/html/rfc5849).
 
 @param path The path to be appended to the HTTP client's base URL and used as the request URL. This path should be a valid temporary credential endpoint.
 @param success A block object to be executed when the request operation finishes parsing a temporary credential successfully. This block has no return value and takes two arguments: the created request operation and the temporary credential created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)authorizeWithSuccess:(void (^)(AFHTTPRequestOperation *operation, NSString *username, NNOAuth2Credential *credential))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (BOOL)handleRedirectionURL:(NSURL *)redirectionURL;

///--------------------------------------
/// @name Interacting with Pocket Service
///--------------------------------------

/**
 Sends a request to the read later service that adds an URL to the reading list of the user with the provided user credential.
 
 @param URL URL to add to the reading list.
 @param title Title for the URL to add to the reading list.
 @param credential Credential for the user adding the URL.
 @param success A block object to be executed when the request operation finishes parsing a token credential successfully. This block has no return value and takes the request operation as the argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)addURL:(NSURL *)URL title:(NSString *)title withCredential:(NNOAuthCredential *)credential
       success:(void (^)(AFHTTPRequestOperation *operation))success
       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
