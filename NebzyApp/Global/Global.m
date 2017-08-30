//
//  Global.m
//  Hiaggo
//
//  Created by XinMa on 8/12/14.
//  Copyright (c) 2014 Jin. All rights reserved.
//

#import "Global.h"

static Global * _sharedManager = nil;
@implementation Global

+ (id)sharedInstance
{
    if (_sharedManager == nil)
    {
        
        @synchronized(self)
        {
            _sharedManager = [[Global alloc] init];
            _sharedManager.tokenFlag = NO;
        }
    }
    return _sharedManager;
}

-(id) init {
    if(self = [super init])
    {
    }
    return self;
}

+(UIImage *)getProfileImage:(NSString *)fbId
{
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fbId]];
    NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    return image;
}

+(UIImage *)getProfileImageFromURL:(NSString *)url
{
    NSURL *pictureURL = [NSURL URLWithString:url];
    NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    return image;
}

+(void) logOut
{
    PFUser *user = [PFUser currentUser];
    [user setObject:@"NO" forKey:@"login"];
    [user saveInBackground];
    [PFUser logOut];
}

@end
