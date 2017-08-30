//
//  ProfileViewController.m
//  NebzyApp
//
//  Created by Admin on 8/2/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "ProfileViewController.h"
#import "Chat/ChatView.h"
#import "recent.h"
#import "RecentView.h"

@implementation ProfileViewController

-(void) viewDidLoad
{
    //self.view.backgroundColor = [UIColor colorWithRed:213.0f/255.0f green:213.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
    
    [self setProfileImage];
}

-(void) viewWillAppear:(BOOL)animated
{
    //self.navigationController.navigationBarHidden = YES;
}

-(void) setProfileImage
{
    Global *g_Data = [Global sharedInstance];
    PFUser *selUser = g_Data.selectedUser;
    NSURL *pictureURL = [NSURL URLWithString:selUser[PF_USER_PICTURE]];
    NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    float oldWidth = image.size.width;
    float oldHeight = image.size.height;
    
    //Set Profile Image
    float newDimension = oldWidth < oldHeight ? oldWidth : oldHeight;
    UIGraphicsBeginImageContext(CGSizeMake(newDimension, newDimension));
    [image drawInRect:CGRectMake((newDimension-oldWidth) / 2, (newDimension-oldHeight) / 2, oldWidth, oldHeight)];
    UIImage *newProfileImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _profileImage.image = newProfileImage;
    _profileImage.layer.borderWidth = 0.0f;
    //_profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    //_profileImage.layer.borderColor = [UIColor colorWithRed:98.0f/255.0f green:196.0f/255.0f blue:73.0f/255.0f alpha:1.0f].CGColor;
    _profileImage.layer.cornerRadius = (_profileImage.frame.size.width) / 2;
    _profileImage.layer.masksToBounds = YES;
    _profileImage.clipsToBounds = YES;
    _profileImage.backgroundColor = [UIColor whiteColor];
    
    // touch action
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnProfileImageAction)];
    tapGesture.numberOfTapsRequired = 1;
    [_profileImage addGestureRecognizer:tapGesture];
    
    
    //Set Blur Background Image
    CGSize bgSize = super.bgImage.frame.size;
    CGFloat xRatio = bgSize.width / oldWidth;
    CGFloat yRatio = bgSize.height / oldHeight;
    CGFloat zoomRatio = xRatio > yRatio ? xRatio : yRatio;
    UIGraphicsBeginImageContext(CGSizeMake(bgSize.width, bgSize.height));
    [image drawInRect:CGRectMake((bgSize.width - oldWidth * zoomRatio) / 2, (bgSize.height - oldHeight * zoomRatio) / 2, oldWidth * zoomRatio, oldHeight * zoomRatio)];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    super.bgImage.image = backgroundImage;
//    super.bgImage.layer.cornerRadius = (super.bgImage.frame.size.width) / 2;
//    _profileImage.layer.masksToBounds = YES;
//    _profileImage.clipsToBounds = YES;
    
    UIBlurEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView;
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    
    UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrantEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancy];
    vibrantEffectView.frame = self.view.bounds;
    
    [super.bgImage addSubview:blurEffectView];
    [super.bgImage addSubview:vibrantEffectView];
    
//    super.bgImage.layer.borderWidth = 2;
//    super.bgImage.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)handleTapOnProfileImageAction {
    
    self.heartImage.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    
    //            [self.view addSubview:popUp];
    [self.heartImage setHidden:NO];
    [UIView animateWithDuration:0.3/1.5 animations:^{
        self.heartImage.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            self.heartImage.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                self.heartImage.transform = CGAffineTransformIdentity;
            }];
        }];
    }];

}

-(IBAction)onMessageView:(id)sender
{
    PFUser *user1 = [PFUser currentUser];
    Global *g_Data = [Global sharedInstance];
    PFUser *user2 = g_Data.selectedUser;
    if([user1.objectId isEqualToString:user2.objectId]) {
        RecentView *recentView = [[RecentView alloc] init];
        [self.navigationController pushViewController:recentView animated:YES];
    } else {
        NSString *groupId = StartPrivateChat(user1, user2);
        [self actionChat:groupId];
    }
}

- (void)actionChat:(NSString *)groupId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    ChatView *chatView = [[ChatView alloc] initWith:groupId];
    chatView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
}


@end
