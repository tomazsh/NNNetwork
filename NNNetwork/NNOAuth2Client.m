//
//  NNOAuth2Client.m
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
#import "NNOAuth2Credential.h"

@implementation NNOAuth2Client

#pragma mark -
#pragma mark Instance Methods

- (void)beginAuthorizationWithPath:(NSString *)path redirectURI:(NSURL *)redirectURI scope:(NSString *)scope state:(NSString *)state success:(void (^)(AFHTTPRequestOperation *, NSString *, NSString *))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"code" forKey:@"response_type"];
    [parameters setValue:self.clientIdentifier forKey:@"client_id"];
    [parameters setValue:redirectURI forKey:@"redirect_uri"];
    [parameters setValue:scope forKey:@"scope"];
    [parameters setValue:state forKey:@"state"];
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseType = [[operation.response allHeaderFields] valueForKey:@"Content-Type"];
        if ([responseType isEqualToString:@"application/x-www-form-urlencoded"]) {
            NSString *responseBody = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            responseObject = [NSDictionary dictionaryWithURLParameterString:responseBody];
        }

        NSString *responseCode = [responseObject valueForKey:@"code"];
        NSString *responseScope = [responseObject valueForKey:@"scope"];
        if (success) {
            success(operation, responseCode, responseScope);
        }
    } failure:failure];
}

- (void)obtainCredentialWithPath:(NSString *)path code:(NSString *)code redirectURI:(NSURL *)redirectURI success:(void (^)(AFHTTPRequestOperation *, NNOAuth2Credential *))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"authorization_code" forKey:@"grant_type"];
    [parameters setValue:@"code" forKey:@"response_type"];
    [parameters setValue:self.clientIdentifier forKey:@"client_id"];
    [parameters setValue:redirectURI forKey:@"redirect_uri"];
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseType = [[operation.response allHeaderFields] valueForKey:@"Content-Type"];
        if ([responseType isEqualToString:@"application/x-www-form-urlencoded"]) {
            NSString *responseBody = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            responseObject = [NSDictionary dictionaryWithURLParameterString:responseBody];
        }
        
        NSString *accessToken = [responseObject valueForKey:@"access_token"];
        NNOAuth2Credential *credential = [[NNOAuth2Credential alloc] initWithAccessToken:accessToken];
        if (success) {
            success(operation, credential);
        }
    } failure:failure];
}

@end
