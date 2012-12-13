//
//  NNOAuth1Credential.m
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

#import "NNOAuth1Credential.h"

@interface NNOAuth1Credential ()

@property(copy, readwrite, nonatomic) NSString *accessSecret;

@end

@implementation NNOAuth1Credential

#pragma mark -
#pragma mark Class Methods

+ (id)emptyCredential
{
    return [[self alloc] initWithAccessToken:@"" accessSecret:@""];
}

+ (id)credentialWithAccessToken:(NSString *)token accessSecret:(NSString *)secret
{
    return [[self alloc] initWithAccessToken:token accessSecret:secret userInfo:nil];
}

+ (id)credentialWithAccessToken:(NSString *)token accessSecret:(NSString *)secret userInfo:(NSDictionary *)userInfo
{
    return [[self alloc] initWithAccessToken:token accessSecret:secret userInfo:userInfo];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithAccessToken:(NSString *)token accessSecret:(NSString *)secret
{
    return [self initWithAccessToken:token accessSecret:secret userInfo:nil];
}

- (id)initWithAccessToken:(NSString *)token accessSecret:(NSString *)secret userInfo:(NSDictionary *)userInfo
{
    self = [super initWithAccessToken:token userInfo:userInfo];
    if (self) {
        _accessSecret = [secret copy];
    }
    return self;
}

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        _accessSecret = [decoder decodeObjectForKey:@"accessSecret"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_accessSecret forKey:@"accessSecret"];
}

#pragma mark -
#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    NNOAuth1Credential *credential = (NNOAuth1Credential *)[super copyWithZone:zone];
    credential.accessSecret = [_accessSecret copyWithZone:zone];
    return credential;
}

@end
