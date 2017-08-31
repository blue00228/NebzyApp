//
//  ArrowLabel.h
//  NebzyApp
//
//  Created by White Snow on 8/31/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
@interface ArrowLabel : UILabel
/**
 *  Background Color of the Badge
 */
@property (nonatomic, strong) IBInspectable UIColor *badgeColor;

/**
 *  Border Color of the Badge
 */
@property (nonatomic, strong) IBInspectable UIColor *badgeBorderColor;

/**
 *  Border width of the badge
 */
@property (nonatomic, assign) IBInspectable CGFloat badgeBorderWidth;


/**
 *  Corner radius of the badge
 */
@property (nonatomic, assign) IBInspectable CGFloat badgeCornerRadius;

/**
 *  Height of the arrow displayed at the bottom of the badge
 *
 *  @discussion If the value is bigger than 30% of the badge height it is cut off to 30% of the badge height automatically
 */
@property (nonatomic, assign) IBInspectable CGFloat bottomArrowHeight;


/**
 *  Tells if the border should be drawn or not for the badge
 */
@property (nonatomic, assign) IBInspectable BOOL drawBadgeBorder;


/**
 *  Tells if the bottom arrow should be drawn, if set to yes ignores bottomArrowHeight, defaults to YES
 */
@property (nonatomic, assign) IBInspectable BOOL showArrow;



@end
