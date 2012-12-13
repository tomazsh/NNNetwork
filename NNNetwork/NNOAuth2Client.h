//
//  NNOAuth2Client.h
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

#import "NNOAuthClient.h"

@class NNOAuth2Credential;

/**
 `NNOAuth2Client` provides a way to communicate with an OAuth 2.0 service.
 
 ### Authorization Process
 
 `NNOAuth2Client` provides methods for a typical three step redirection-based authorization process with authorization code grant. You should generally implement the following approach:
 
 1. Request authorization with service provider via `beginAuthorizationWithPath:redirectURI:scope:state:success:failure:`.
 2. Navigate to resource owner authorization endpoint in Safari or a dedicated `UIWebView` and allow the user to grant your application access.
 3. Use `obtainCredentialWithPath:code:redirectURI:success:failure:` to obtain credential with access token from provider.
 
 ### Subclassing Notes
 
 You should subclass `NNOAuth2Client` as you would `AFHTTPClient`. If your OAuth service requires a specialized authorization or authentication technique, you should also consider overriding other methods.
 
 #### Methods to Override
 
 If you wish to change the authorization mechanism, you should override any of the methods `beginAuthorizationWithPath:redirectURI:scope:state:success:failure:` or `obtainCredentialWithPath:code:redirectURI:success:failure:` depending on what part you wish to change.
 
 If you wish to change the authentication mechanism, you should override mehods as described for `NNOAuthClient`.
 */
@interface NNOAuth2Client : NNOAuthClient 

///------------------------
/// @name Authorizing Users
///------------------------

/**
 Creates an `AFHTTPRequestOperation` with a `POST` request, and enqueues it to the OAuth client’s operation queue. On completion it parses the response and passes authorization code and scope to the `success` block parameter. For client to be able to parse the response successfully, `path` should be a valid authorization endpoint. To learn more about this, see the 4.1.1 section of [The OAuth 2.0 Authorization Framework](http://tools.ietf.org/html/draft-ietf-oauth-v2-31).
 
 @param path The path to be appended to the HTTP client's base URL and used as the request URL. This path should be a valid authorization endpoint.
 @param redirectURI The URI to redirect back to after user grants or denies access.
 @param scope The scope of the access request.
 @param state An opaque value used by the client to maintain state between the request and callback.
 @param success A block object to be executed when the request operation finishes parsing a temporary credential successfully. This block has no return value and takes three arguments: the created request operation, authorization code and scope.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)beginAuthorizationWithPath:(NSString *)path
                       redirectURI:(NSURL *)redirectURI
                             scope:(NSString *)scope
                             state:(NSString *)state
                           success:(void (^)(AFHTTPRequestOperation *operation, NSString *code, NSString *scope))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `POST` request, and enqueues it to the OAuth client’s operation queue. On completion it parses the response and passes account credential to the `success` block parameter. For client to be able to parse the response successfully, `path` should be a valid token endpoint. To learn more about this, see the 4.1.3 section of [The OAuth 2.0 Authorization Framework](http://tools.ietf.org/html/draft-ietf-oauth-v2-31).
 
 @param path The path to be appended to the HTTP client's base URL and used as the request URL. This path should be a valid token endpoint.
 @param code Authorization code for the request.
 @param redirectURI The URI to redirect back to after user grants or denies access.
 @param success A block object to be executed when the request operation finishes parsing a temporary credential successfully. This block has no return value and takes two arguments: the created request operation and parsed credential.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (void)obtainCredentialWithPath:(NSString *)path
                            code:(NSString *)code
                     redirectURI:(NSURL *)redirectURI
                         success:(void (^)(AFHTTPRequestOperation *operation, NNOAuth2Credential *credential))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
