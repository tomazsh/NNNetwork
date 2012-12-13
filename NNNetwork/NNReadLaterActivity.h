//
//  NNReadLaterActivity.h
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

#import <UIKit/UIKit.h>
#import "NNOAuthClient.h"
#import "NNReadLaterClient.h"

@class NNReadLaterActivity, NNOAuthClient;

@protocol NNReadLaterActivityDelegate <NSObject>

@optional

/**
 If you do not implement this method in your delegate, activity will not be shown in activity view controller.
 */
- (void)readLaterActivityNeedsCredential:(NNReadLaterActivity *)activity;

- (void)readLaterActivity:(NNReadLaterActivity *)activity
         didFinishWithURL:(NSURL *)url
                operation:(AFHTTPRequestOperation *)operation
                    error:(NSError *)error;

@end

extern NSString * const NNReadLaterActivityType;

/**
 The `NNReadLaterActivity` class is an abstract class that you subclass in order to implement specific read later services. A service takes a number of `NSURL` objects and adds them to the reading list. Activity objects are used in conjunction with a UIActivityViewController object, which is responsible for presenting services to the user.
 
 You should subclass `NNReadLaterActivity` only if you want to provide custom read later services to the user. `NNNetwork` already provides support for Instapaper, Pocket and Readability services, but you can implement your own.
 
 ## Subclassing Notes
 
 This class must be subclassed before it can be used. The job of an activity object is to act on the data provided to it and to provide some meta information that iOS can display to the user. For more complex services, an activity object can also display a custom user interface and use it to gather additional information from the user.
 
 ### Methods to Override
 
 You should consider overriding the `client` property if you want to return a default client for all activity objects, such as a `sharedClient` provided by `NNReadLaterClient` protocol.
 
 `NNReadLaterActivity` displays a title that it obtains from `client`'s `name`parameter. You should override `activityTitle` if you want to change this title.
 
 `NNReadLaterActivity` displays an image with the same name as the subclass you have created. You should override `activityImage` if you want to change this image.
 
 */
@interface NNReadLaterActivity : UIActivity {
    @private
    NNOAuthClient<NNReadLaterClient> *_client;
    NNOAuthCredential *_credential;
    NSMutableArray *_URLArray;
}

///-----------------------------------------------
/// @name Accessing Read Later Activity Properties
///-----------------------------------------------

/**
 Delegate for activity. Most conform to the `NNReadLaterActivityDelegate` protocol.
 */
@property(weak, nonatomic) id<NNReadLaterActivityDelegate> delegate;

/**
 Read later client to display activity for.
 */
@property(strong, readonly, nonatomic) NNOAuthClient<NNReadLaterClient> *client;

/**
 User credential for the user adding the URLs.
 */
@property(strong, readonly, nonatomic) NNOAuthCredential *credential;

/**
 URLs obtained by the activity for adding to reading list.
 */
@property(strong, readonly, nonatomic) NSArray *URLArray;

///-------------------------------------
/// @name Creating Read Later Activities
///-------------------------------------

/**
 Initializes a newly allocated activity with provided user credential to be used.
 
 @param credential Credential for the user adding the URLs. May not be `nil`.
 
 @return An initialized `NNReadLaterActivity` object.
 */
- (id)initWithCredential:(NNOAuthCredential *)credential;

@end
