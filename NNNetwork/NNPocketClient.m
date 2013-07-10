//
//  NNPocketClient.m
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

#import "NNPocketClient.h"
#import "NNOAuth2Credential.h"
#import "NNOAuthCredential.h"
#import "AFHTTPRequestOperation.h"
#import "NSDictionary+NNNetwork.h"
#import "NSString+NNNetwork.h"

NSString * const NNPocketClientName = @"Pocket";
NSString * const NNPocketClientOAuthWebAuthorizationBaseString = @"https://getpocket.com/auth/authorize";
NSString * const NNPocketClientOAuthAppAuthorizationBaseString = @"pocket-oauth-v1:///authorize";
NSString * const NNPocketClientBaseString = @"https://getpocket.com/v3/";
NSString * const NNPocketClientOAuthRequestPath = @"oauth/request";
NSString * const NNPocketClientOAuthAuthorizationPath = @"oauth/authorize";
NSString * const NNPocketClientAddURLPath = @"add";

typedef void(^AuthorizationSuccessBlock)(AFHTTPRequestOperation *, NSString *, NNOAuth2Credential *);
typedef void(^AuthorizationFailureBlock)(AFHTTPRequestOperation *, NSError *);

@interface NNPocketClient () {
    @private
    NSString *_code;
    AuthorizationSuccessBlock _authorizationSuccessBlock;
    AuthorizationFailureBlock _authorizationFailureBlock;
}

@property(copy, nonatomic) NSString *code;
@property(copy, nonatomic) AuthorizationSuccessBlock authorizationSuccessBlock;
@property(copy, nonatomic) AuthorizationFailureBlock authorizationFailureBlock;

@end

@implementation NNPocketClient

#pragma mark -
#pragma mark Public Methods

- (void)authorizeWithSuccess:(void (^)(AFHTTPRequestOperation *, NSString *, NNOAuth2Credential *))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSURL *redirectURL = [self redirectURLFromScheme];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:self.clientIdentifier forKey:@"consumer_key"];
    [parameters setValue:redirectURL forKey:@"redirect_uri"];
    [self postPath:NNPocketClientOAuthRequestPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseType = [[operation.response allHeaderFields] valueForKey:@"Content-Type"];
        if ([responseType isEqualToString:@"application/x-www-form-urlencoded"]) {
            NSString *responseBody = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            responseObject = [NSDictionary dictionaryWithURLParameterString:responseBody];
        }
        
        self.code = [responseObject valueForKey:@"code"];
        self.authorizationSuccessBlock = success;
        self.authorizationFailureBlock = failure;
        
        NSString *encodedRedirectURI = [[redirectURL absoluteString] stringByEncodingForURLQuery];
        NSURL *authorizeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?request_token=%@&redirect_uri=%@", NNPocketClientOAuthAppAuthorizationBaseString, self.code, encodedRedirectURI]];
        if (![[UIApplication sharedApplication] canOpenURL:authorizeURL]) {
            authorizeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?request_token=%@&redirect_uri=%@", NNPocketClientOAuthWebAuthorizationBaseString, self.code, encodedRedirectURI]];
        }
        [[UIApplication sharedApplication] openURL:authorizeURL];
    } failure:failure];
}

- (BOOL)handleRedirectionURL:(NSURL *)redirectionURL
{
    if (!self.code || ![[redirectionURL scheme] isEqualToString:self.scheme]) {
        return NO;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:self.clientIdentifier forKey:@"consumer_key"];
    [parameters setValue:self.code forKey:@"code"];
    [self postPath:NNPocketClientOAuthAuthorizationPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseType = [[operation.response allHeaderFields] valueForKey:@"Content-Type"];
        if ([responseType isEqualToString:@"application/x-www-form-urlencoded"]) {
            NSString *responseBody = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            responseObject = [NSDictionary dictionaryWithURLParameterString:responseBody];
        }
        
        NSString *username = [responseObject valueForKey:@"username"];
        NSString *accessToken = [responseObject valueForKey:@"access_token"];
        NNOAuth2Credential *credential = [[NNOAuth2Credential alloc] initWithAccessToken:accessToken];
        if (self.authorizationSuccessBlock) {
            self.authorizationSuccessBlock(operation, username, credential);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (self.authorizationFailureBlock) {
            self.authorizationFailureBlock(operation, error);
        }
    }];
    
    return YES;
}

- (NSURL *)redirectURLFromScheme
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@:///authorizationFinished", self.scheme]];
}

- (void)addURL:(NSURL *)URL title:(NSString *)title withCredential:(NNOAuthCredential *)credential success:(void (^)(AFHTTPRequestOperation *operation))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:self.clientIdentifier forKey:@"consumer_key"];
    [parameters setValue:credential.accessToken forKey:@"access_token"];
    [parameters setValue:URL forKey:@"url"];
    [parameters setValue:title forKey:@"title"];
    
    [self postPath:NNPocketClientAddURLPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
}

#pragma mark -
#pragma mark NNReadLaterClient

+ (id)sharedClient
{
    static NNPocketClient *SharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedClient = [[NNPocketClient alloc] initWithBaseURL:[NSURL URLWithString:NNPocketClientBaseString]];
    });
    return SharedClient;
}

- (NSString *)name
{
    return NNPocketClientName;
}

- (void)addURL:(NSURL *)URL withCredential:(NNOAuthCredential *)credential success:(void (^)(AFHTTPRequestOperation *))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    [self addURL:URL title:nil withCredential:credential success:success failure:failure];
}

@end
