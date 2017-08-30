//
//  ImageWallViewController.h
//  FBParse
//

#import "DataStore.h"

@interface ImageWallTableImageCell : UITableViewCell
- (void)setPictureWithImage:(UIImage *)profileImage;
@end

@interface ImageWallTableCommentCell : UITableViewCell
- (void)setPictureWithFBId:(NSString *)fbId;
- (void)setPictureWithImage:(UIImage *)profileImage;
@end

@interface ImageWallTableNewCommentCell : UITableViewCell

@end

@interface ImageWallViewController : UITableViewController
+ (void) addComment:(NSString *)comment toWallImage:(WallImage *)wallImage;
- (void) getWallImagesSince:(NSDate *)lastUpdate;
@end
