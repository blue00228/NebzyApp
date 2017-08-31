//
//  UIBezierPath+dqd_arrowhead.h
//  NebzyApp
//
//  Created by White Snow on 8/31/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (dqd_arrowhead)

+ (UIBezierPath *)dqd_bezierPathWithArrowFromPoint:(CGPoint)startPoint
                                           toPoint:(CGPoint)endPoint
                                         tailWidth:(CGFloat)tailWidth
                                         headWidth:(CGFloat)headWidth
                                        headLength:(CGFloat)headLength;
+ (UIBezierPath*) createBezierPathForSize:(CGSize) size
                            arrowPosition:(CGPoint)arrowPosition;

@end
