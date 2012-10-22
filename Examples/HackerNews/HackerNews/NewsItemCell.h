//
//  NewsItemCell.h
//  NNNetworkExample
//
//  Created by Tomaz Nedeljko on 16/10/12.
//  Copyright (c) 2012 Tomaz Nedeljko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsItemCell : UITableViewCell

@property(strong, readonly, nonatomic) IBOutlet UILabel *titleLabel;
@property(strong, readonly, nonatomic) IBOutlet UILabel *linkLabel;
@property(strong, readonly, nonatomic) IBOutlet UILabel *detailLabel;

@end
