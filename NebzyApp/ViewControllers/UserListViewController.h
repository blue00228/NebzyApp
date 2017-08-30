//
//  UserListViewController.h
//  NebzyApp
//
//  Created by Admin on 7/16/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "MyViewController.h"
#import <ParseUI/ParseUI.h>

@interface UserListViewController : PFQueryCollectionViewController <UIAlertViewDelegate, UIGestureRecognizerDelegate>

@property PFGeoPoint *myGeoPoint;

@end
