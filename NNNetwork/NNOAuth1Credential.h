//
//  NNOAuth1Credential.h
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

#import "NNOAuthCredential.h"

@interface NNOAuth1Credential : NNOAuthCredential {
    @private
    NSString *_accessSecret;
}

///------------------------------------------------------
/// @name Initializing and Creating OAuth 1.0 Credentials
///------------------------------------------------------

/**
 Initializes a newly allocated credential with provided access token and access secret.
 
 @param token Credential access token, obtained from an OAuth 1.0 service. May not be `nil`.
 @param secret Credential access secret, obtained from an OAuth 1.0 service. May not be `nil`.
 
 @return An initialized `NNOAuthCredential` object.
 */
- (id)initWithAccessToken:(NSString *)token accessSecret:(NSString *)secret;

/**
 Initializes a newly allocated credential with provided access token, access secret and user information.
 
 @param token Credential access token, obtained from an OAuth 1.0 service. May not be `nil`.
 @param secret Credential access secret, obtained from an OAuth 1.0 service. May not be `nil`.
 @param userInfo The user information dictionary for the newly allocated credential. Keys and object in this dictionary should be `NSCoding` conformant. May be `nil`.
 
 @return An initialized `NNOAuthCredential` object.
 */
- (id)initWithAccessToken:(NSString *)token accessSecret:(NSString *)secret userInfo:(NSDictionary *)userInfo;

/**
 Creates and returns a new credential with provided access token and access secret.
 
 @param token Credential access token, obtained from an OAuth 1.0 service. May not be `nil`.
 @param secret Credential access secret, obtained from an OAuth 1.0 service. May not be `nil`.
 
 @return A new `NNOAuthCredential` object.
 */
+ (id)credentialWithAccessToken:(NSString *)token accessSecret:(NSString *)secret;

/**
 Creates and returns a new credential with provided access token, access secret and user information.
 
 @param token Credential access token, obtained from an OAuth 1.0 service. May not be `nil`.
 @param secret Credential access secret, obtained from an OAuth 1.0 service. May not be `nil`.
 @param userInfo The user information dictionary for the new credential. May be `nil`.
 
 @return A new `NNOAuthCredential` object.
 */
+ (id)credentialWithAccessToken:(NSString *)token accessSecret:(NSString *)secret userInfo:(NSDictionary *)userInfo;

///------------------------------------------------
/// @name Accessing OAuth 1.0 Credential Properties
///------------------------------------------------

/**
 Access secret for credential.
 
 @discussion If you plan to use a credential with a `NNOAuth1Client` instance, this value should not be nil. If you do not have an access secret, this value should be an empty string.
 */
@property(copy, readonly, nonatomic) NSString *accessSecret;

@end
