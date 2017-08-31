//
//  UIBezierPath+dqd_arrowhead.m
//  NebzyApp
//
//  Created by White Snow on 8/31/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "UIBezierPath+dqd_arrowhead.h"

#define kArrowPointCount 7

@implementation UIBezierPath (dqd_arrowhead)

static inline float radians(double degrees)
{
    return degrees * M_PI / 180;
}

static inline CGPoint CGPointOffset(CGPoint originalPoint, CGFloat dx, CGFloat dy)
{
    return CGPointMake(originalPoint.x + dx, originalPoint.y + dy);
}

static inline CGPoint CGPointOffsetByPoint(CGPoint originalPoint, CGPoint offsetPoint)
{
    return CGPointOffset(originalPoint, offsetPoint.x, offsetPoint.y);
}

CGFloat _shadowPadding = 3.0f;
CGFloat _cornerRadius  = 15.0f;
CGFloat _headerHeight  = 40.0f;
CGSize  _innerPadding  = (CGSize){10, 10};
CGSize  _arrowSize     = (CGSize){18, 11};

+ (UIBezierPath *)dqd_bezierPathWithArrowFromPoint:(CGPoint)startPoint
                                           toPoint:(CGPoint)endPoint
                                         tailWidth:(CGFloat)tailWidth
                                         headWidth:(CGFloat)headWidth
                                        headLength:(CGFloat)headLength {
    CGFloat length = hypotf(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
    
    CGPoint points[kArrowPointCount];
    [self dqd_getAxisAlignedArrowPoints:points
                              forLength:length
                              tailWidth:tailWidth
                              headWidth:headWidth
                             headLength:headLength];
    
    CGAffineTransform transform = [self dqd_transformForStartPoint:startPoint
                                                          endPoint:endPoint
                                                            length:length];
    
    CGMutablePathRef cgPath = CGPathCreateMutable();
    CGPathAddLines(cgPath, &transform, points, sizeof points / sizeof *points);
    CGPathCloseSubpath(cgPath);
    
    UIBezierPath *uiPath = [UIBezierPath bezierPathWithCGPath:cgPath];
    CGPathRelease(cgPath);
    return uiPath;
}

+ (void)dqd_getAxisAlignedArrowPoints:(CGPoint[kArrowPointCount])points
                            forLength:(CGFloat)length
                            tailWidth:(CGFloat)tailWidth
                            headWidth:(CGFloat)headWidth
                           headLength:(CGFloat)headLength {
    CGFloat tailLength = length - headLength;
    points[0] = CGPointMake(0, tailWidth / 2);
    points[1] = CGPointMake(tailLength, tailWidth / 2);
    points[2] = CGPointMake(tailLength, headWidth / 2);
    points[3] = CGPointMake(length, 0);
    points[4] = CGPointMake(tailLength, -headWidth / 2);
    points[5] = CGPointMake(tailLength, -tailWidth / 2);
    points[6] = CGPointMake(0, -tailWidth / 2);
}

+ (CGAffineTransform)dqd_transformForStartPoint:(CGPoint)startPoint
                                       endPoint:(CGPoint)endPoint
                                         length:(CGFloat)length {
    CGFloat cosine = (endPoint.x - startPoint.x) / length;
    CGFloat sine = (endPoint.y - startPoint.y) / length;
    return (CGAffineTransform){ cosine, sine, -sine, cosine, startPoint.x, startPoint.y };
}

+ (UIBezierPath*) createBezierPathForSize:(CGSize) size
                            arrowPosition:(CGPoint)arrowPosition

{
    UIBezierPath* result = [UIBezierPath bezierPath];
    
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGPoint startArrowPoint = CGPointZero;
    CGPoint endArrowPoint = CGPointZero;
    CGPoint topArrowPoint = CGPointZero;
    CGPoint offset = CGPointMake(_shadowPadding, _shadowPadding);
    CGPoint tl = CGPointZero;
    width -= _shadowPadding * 2;
    height -= _shadowPadding * 2;
    
    startArrowPoint = CGPointMake(-_arrowSize.width / 2, -_arrowSize.height);
    endArrowPoint = CGPointMake(_arrowSize.width / 2, -_arrowSize.height);
    offset = CGPointOffset(offset, arrowPosition.x, height + _arrowSize.height);
    
    startArrowPoint = CGPointOffsetByPoint(startArrowPoint, offset);
    endArrowPoint = CGPointOffsetByPoint(endArrowPoint, offset);
    topArrowPoint = CGPointOffsetByPoint(topArrowPoint, offset);
    
    void (^createBezierArrow)(void) = ^{
        [result addLineToPoint: startArrowPoint];
        [result addLineToPoint: topArrowPoint];
        [result addLineToPoint: endArrowPoint];
    };
    
    // starting from bottom-left corner
    [result moveToPoint: CGPointMake(tl.x + _shadowPadding
                                     , tl.y + _shadowPadding + height - _cornerRadius)];
    // creating arc to a bottom line
    [result addArcWithCenter:CGPointMake(tl.x + _shadowPadding + _cornerRadius
                                         , tl.y + _shadowPadding + height - _cornerRadius)
                      radius:_cornerRadius
                  startAngle:radians(180)
                    endAngle:radians(90)
                   clockwise:NO];
    
    createBezierArrow();
    
    // same steps for bottom-right corner
    [result addLineToPoint: CGPointMake(tl.x + _shadowPadding + width - _cornerRadius
                                        , tl.y + _shadowPadding + height)];
    [result addArcWithCenter:CGPointMake(tl.x + _shadowPadding + width - _cornerRadius
                                         , tl.y + _shadowPadding + height - _cornerRadius)
                      radius:_cornerRadius
                  startAngle:radians(90)
                    endAngle:radians(0)
                   clockwise:NO];
    
    // same steps for top-right corner
    [result addLineToPoint: CGPointMake(tl.x + _shadowPadding + width
                                        , tl.y + _shadowPadding + _cornerRadius)];
    [result addArcWithCenter:CGPointMake(tl.x + _shadowPadding + width - _cornerRadius
                                         , tl.y + _shadowPadding + _cornerRadius)
                      radius:_cornerRadius
                  startAngle:radians(0)
                    endAngle:radians(-90)
                   clockwise:NO];
    
    // same steps for top-left corner
    [result addLineToPoint: CGPointMake(tl.x + _shadowPadding + _cornerRadius
                                        , tl.y + _shadowPadding)];
    [result addArcWithCenter:CGPointMake(tl.x + _shadowPadding + _cornerRadius
                                         , tl.y + _shadowPadding + _cornerRadius)
                      radius:_cornerRadius
                  startAngle:radians(-90)
                    endAngle:radians(-180)
                   clockwise:NO];
    
    // return back to the starting point
    [result addLineToPoint: CGPointMake(tl.x + _shadowPadding
                                        , tl.y + _shadowPadding + height - _cornerRadius)];
    
    [result closePath];
    
    return result;
}
@end
