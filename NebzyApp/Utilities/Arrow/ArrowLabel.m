//
//  ArrowLabel.m
//  NebzyApp
//
//  Created by White Snow on 8/31/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "ArrowLabel.h"

@implementation ArrowLabel


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [super drawRect:rect];
    
    // checking maximum property values
    
    if (_bottomArrowHeight >= self.bounds.size.height*0.3f) {
        _bottomArrowHeight = self.bounds.size.height*0.3f;
    }
    
    if (_badgeCornerRadius >= (self.bounds.size.height-_bottomArrowHeight)/2.0) {
        _badgeCornerRadius = (self.bounds.size.height-_bottomArrowHeight)/2.0;
    }
    
    
    
    
    // Drawing with a white stroke color
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, _badgeColor.CGColor);
    
    CGContextSetStrokeColorWithColor(context, _badgeBorderColor.CGColor);
    
    CGContextSetLineWidth(context, _badgeBorderWidth);
    
    
    //CGRect drawingRect = CGRectInset(rect, -1, -1);
    
    
    //CGContextSet
    
    CGRect rrect = CGRectInset(CGRectMake(0, 0, rect.size.width, rect.size.height), _badgeBorderWidth/2.0f, _badgeBorderWidth/2.0f);
    
    if (_drawBadgeBorder) {
        rrect = CGRectInset(CGRectMake(0, 0, rect.size.width, rect.size.height), _badgeBorderWidth/2.0f, _badgeBorderWidth/2.0f);
    }else {
        rrect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    }
    
    CGFloat radius = _badgeCornerRadius;
    
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect);
    
    CGFloat maxy;
    
    if(_showArrow) {
        maxy = CGRectGetMaxY(rrect);
        miny = CGRectGetMinY(rrect) + _bottomArrowHeight;
    }else {
        maxy = CGRectGetMaxY(rrect);
    }
    
    
    
    // Draw the badge shape
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx - _bottomArrowHeight , miny, radius);
    if (_showArrow) {
        // DRAW THE ARROW AT THE TOP
        CGContextAddLineToPoint(context, midx -_bottomArrowHeight  , miny);
        CGContextAddLineToPoint(context, midx , miny-_bottomArrowHeight);
        CGContextAddLineToPoint(context, midx+_bottomArrowHeight, miny);
        
    }
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    
    CGContextClosePath(context);
    
    if (_drawBadgeBorder) {
        CGContextDrawPath(context, kCGPathFillStroke);
    }else {
        CGContextDrawPath(context, kCGPathFill);
    }

}


@end
