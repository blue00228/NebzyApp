//
//  UserProfileCollectionViewCell.m
//  NebzyApp
//
//  Created by Admin on 7/20/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "UserProfileCollectionViewCell.h"

@implementation UserProfileCollectionViewCell

- (void)setPictureWithFBId:(NSString *)fbId
{
    self.backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    self.backgroundColor = [UIColor clearColor];
    
    UIImage *image = [Global getProfileImage:fbId];
    float oldWidth = image.size.width;
    float oldHeight = image.size.height;
    float newDimension = oldWidth < oldHeight ? oldWidth : oldHeight;
    UIGraphicsBeginImageContext(CGSizeMake(newDimension, newDimension));
    [image drawInRect:CGRectMake((newDimension-oldWidth) / 2, (newDimension-oldHeight) / 2, oldWidth, oldHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _itemImageView.backgroundColor = [UIColor whiteColor];
    _itemImageView.image = newImage;
    _itemImageView.layer.borderWidth = 0.0f;
    _itemImageView.layer.borderColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0f].CGColor;//[UIColor whiteColor].CGColor;
    _itemImageView.layer.cornerRadius = (self.frame.size.width) / 2;
    _itemImageView.layer.masksToBounds = YES;
    _itemImageView.clipsToBounds = YES;
    
}

- (void)setPictureWithURL:(NSString *)url
{
    self.backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    self.backgroundColor = [UIColor clearColor];
    
    NSURL *pictureURL = [NSURL URLWithString:url];
    NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    float oldWidth = image.size.width;
    float oldHeight = image.size.height;
    float newDimension = oldWidth < oldHeight ? oldWidth : oldHeight;
    UIGraphicsBeginImageContext(CGSizeMake(newDimension, newDimension));
    [image drawInRect:CGRectMake((newDimension-oldWidth) / 2, (newDimension-oldHeight) / 2, oldWidth, oldHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _itemImageView.backgroundColor = [UIColor whiteColor];
    _itemImageView.image = newImage;
    _itemImageView.layer.borderWidth = 0.0f;
    _itemImageView.layer.borderColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0f].CGColor;//[UIColor whiteColor].CGColor;
    _itemImageView.layer.cornerRadius = (self.frame.size.width) / 2;
    _itemImageView.layer.masksToBounds = YES;
    _itemImageView.clipsToBounds = YES;
    
}

@end
