//
//  AccountsViewController.h
//  NNNetworkExample
//
//  Created by Tomaz Nedeljko on 16/10/12.
//  Copyright (c) 2012 Tomaz Nedeljko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddAccountViewController.h"

@class AccountsViewController;
@protocol AccountsViewControllerDelegate <NSObject>

- (void)accountsViewControllerDidFinish:(AccountsViewController *)controller;

@end

@interface AccountsViewController : UITableViewController <AddAccountViewControllerDelegate, UIActionSheetDelegate> {
    @private
    NSArray *_readLaterClients;
}

@property(weak, nonatomic) id<AccountsViewControllerDelegate> delegate;
@property(strong, readonly, nonatomic) NSArray *readLaterClients;

- (IBAction)done:(id)sender;

@end
