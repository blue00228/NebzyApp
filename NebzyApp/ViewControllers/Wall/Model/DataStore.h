//
//  DataStore.h
//  FBParse
//
//  Created by Toby Stephens on 14/07/2013.
//  Copyright (c) 2013 Toby Stephens. All rights reserved.
//
#import <Parse/Parse.h>

@interface WallImage : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) id objectId;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UIImage *userPicture;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSMutableArray *comments;
@end

@interface WallImageComment : NSObject
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UIImage *userPicture;
@property (nonatomic, strong) NSDate *createdDate;
@end


@interface DataStore : NSObject

@property (nonatomic, strong) NSMutableDictionary *fbFriends;
@property (nonatomic, strong) NSMutableArray *wallImages;
@property (nonatomic, strong) NSMutableDictionary *wallImageMap;

+ (DataStore *) instance;
- (void) reset;

@end
