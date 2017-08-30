//
//  UserProfileCollectionViewCell.h
//  NebzyApp
//
//  Created by Admin on 7/20/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/PFCollectionViewCell.h>

@interface UserProfileCollectionViewCell : PFCollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *itemImageView;
@property (nonatomic, weak) IBOutlet UIImageView *heartImage;

- (void)setPictureWithFBId:(NSString *)fbId;
- (void)setPictureWithURL:(NSString *)url;

@end
