//
//  Global.h
//  Hiaggo
//
//  Created by XinMa on 8/12/14.
//  Copyright (c) 2014 Jin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Global : NSObject

@property BOOL tokenFlag;
@property PFUser *selectedUser;

+ (id)sharedInstance;
+ (UIImage *) getProfileImage:(NSString *)fbId;
+(UIImage *)getProfileImageFromURL:(NSString *)url;
+ (void) logOut;


@end
