//
//  ImageWallViewController.m
//  FBParse
//

#import "ImageWallViewController.h"
#import "NSOperationQueue+SharedQueue.h"
#import "ProgressHUD.h"

@interface ImageWallTableImageCell ()
@property (nonatomic, strong) IBOutlet UIImageView *profilePicture;
@property (nonatomic, strong) IBOutlet UILabel *lblPost;
@property NSString *userObjectId;
@end

@implementation ImageWallTableImageCell

- (void)setPictureWithImage:(UIImage *)profileImage
{
    _lblPost.layer.borderColor = [UIColor greenColor].CGColor;
    _lblPost.layer.borderWidth = 1.0f;
    _lblPost.layer.cornerRadius = 3;
    
    UIImage *image = profileImage;
    float oldWidth = image.size.width;
    float oldHeight = image.size.height;
    float newDimension = oldWidth < oldHeight ? oldWidth : oldHeight;
    UIGraphicsBeginImageContext(CGSizeMake(newDimension, newDimension));
    [image drawInRect:CGRectMake((newDimension-oldWidth) / 2, (newDimension-oldHeight) / 2, oldWidth, oldHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _profilePicture.backgroundColor = [UIColor clearColor];
    _profilePicture.image = newImage;
    _profilePicture.layer.borderWidth = 0.0f;
    _profilePicture.layer.borderWidth = .0f;
    _profilePicture.layer.borderColor = [UIColor colorWithRed:51.0f/255.0f green:255.0f/255.0f blue:51.0f/255.0f alpha:1.0f].CGColor;//[UIColor whiteColor].CGColor;
    _profilePicture.layer.cornerRadius = (_profilePicture.frame.size.width) / 2;
    _profilePicture.layer.masksToBounds = YES;
    _profilePicture.clipsToBounds = YES;
}

-(IBAction)onProfileClick:(id)sender {
    DataStore *store = [DataStore instance];
    PFUser *userObject = [store.fbFriends objectForKey:_userObjectId];
    Global *g_Data = [Global sharedInstance];
    g_Data.selectedUser = userObject;
    //[self. performSegueWithIdentifier:@"Segue_Profile" sender:nil];
}

@end

@interface ImageWallTableCommentCell ()
@property (nonatomic, strong) IBOutlet UIImageView *profilePicture;
@property (nonatomic, strong) IBOutlet UILabel *comment;
@end

@implementation ImageWallTableCommentCell

- (void)setPictureWithFBId:(NSString *)fbId
{
    UIImage *image = [Global getProfileImage:fbId];
    float oldWidth = image.size.width;
    float oldHeight = image.size.height;
    float newDimension = oldWidth < oldHeight ? oldWidth : oldHeight;
    UIGraphicsBeginImageContext(CGSizeMake(newDimension, newDimension));
    [image drawInRect:CGRectMake((newDimension-oldWidth) / 2, (newDimension-oldHeight) / 2, oldWidth, oldHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _profilePicture.backgroundColor = [UIColor clearColor];
    _profilePicture.image = newImage;
    _profilePicture.layer.borderWidth = 0.0f;
    _profilePicture.layer.borderColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0f].CGColor;//[UIColor whiteColor].CGColor;
    _profilePicture.layer.cornerRadius = (_profilePicture.frame.size.width) / 2;
    _profilePicture.layer.masksToBounds = YES;
    _profilePicture.clipsToBounds = YES;
}

- (void)setPictureWithImage:(UIImage *)profileImage
{
    UIImage *image = profileImage;
    float oldWidth = image.size.width;
    float oldHeight = image.size.height;
    float newDimension = oldWidth < oldHeight ? oldWidth : oldHeight;
    UIGraphicsBeginImageContext(CGSizeMake(newDimension, newDimension));
    [image drawInRect:CGRectMake((newDimension-oldWidth) / 2, (newDimension-oldHeight) / 2, oldWidth, oldHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _profilePicture.backgroundColor = [UIColor clearColor];
    _profilePicture.image = newImage;
    _profilePicture.layer.borderWidth = 1.0f;
    _profilePicture.layer.borderColor = [UIColor colorWithRed:51.0f/255.0f green:255.0f/255.0f blue:51.0f/255.0f alpha:1.0f].CGColor;//[UIColor whiteColor].CGColor;
    _profilePicture.layer.cornerRadius = (_profilePicture.frame.size.width) / 2;
    _profilePicture.layer.masksToBounds = YES;
    _profilePicture.clipsToBounds = YES;
}

@end

@interface ImageWallTableNewCommentCell () <UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UITextField *txtComment;
@property (nonatomic, strong) WallImage *wallImage;

@end

@implementation ImageWallTableNewCommentCell
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	if (_txtComment.text.length == 0) return YES;
	
	// We have a new comment, so send it off
	[_txtComment resignFirstResponder];
	[ImageWallViewController addComment:_txtComment.text toWallImage:_wallImage];
	[_txtComment setText:@""];
	
	return YES;
}
@end


@interface ImageWallViewController () {
	NSDate *_lastImageUpdate;
	NSDate *_lastCommentUpdate;
	NSDateFormatter *_dateFormatter;
    NSMutableParagraphStyle *text_style;
}
@end


@implementation ImageWallViewController

-(void) viewWillAppear:(BOOL)animated
{
    // Initialize the last updated dates
    _lastImageUpdate = [NSDate distantPast];
    _lastCommentUpdate = [NSDate distantPast];
    
    DataStore *dataStore = [DataStore instance];
    [dataStore.wallImages removeAllObjects];
    [dataStore.wallImageMap removeAllObjects];
    [self refreshImageWall:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create a re-usable NSDateFormatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MMM d, h:mm a"];
    
    // Initialize the last updated dates
    _lastImageUpdate = [NSDate distantPast];
    _lastCommentUpdate = [NSDate distantPast];
    
    DataStore *dataStore = [DataStore instance];
    [dataStore.wallImages removeAllObjects];
    [dataStore.wallImageMap removeAllObjects];
    
	// If we are using iOS 6+, put a pull to refresh control in the table
	if (NSClassFromString(@"UIRefreshControl") != Nil) {
		UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
		refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
		[refreshControl addTarget:self action:@selector(refreshImageWall:) forControlEvents:UIControlEventValueChanged];
		self.refreshControl = refreshControl;
	}
	
	// Get the Wall Images from Parse
	[self refreshImageWall:nil];
	
	// Listen for image downloads so that we can refresh the image wall
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(imageDownloaded:)
												 name:N_ImageDownloaded
											   object:nil];
	
	// Listen for profile picture downloads so that we can refresh the image wall
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(imageDownloaded:)
												 name:N_ProfilePictureLoaded
											   object:nil];
	
	// Listen for uploaded comments so that we can refresh the image wall table
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(commentUploaded:)
												 name:N_CommentUploaded
											   object:nil];
	
	// Listen for new image uploads so that we can refresh the image wall table
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(imageUploaded:)
												 name:N_ImageUploaded
											   object:nil];
    
    text_style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    text_style.alignment = NSTextAlignmentLeft;
    text_style.firstLineHeadIndent = 10.0f;
    text_style.headIndent = 10.0f;
    text_style.tailIndent = -10.0f;
    
}

- (void) refreshImageWall:(UIRefreshControl *)refreshControl
{
    [ProgressHUD show:@"Loading" Interaction:NO];
	if (refreshControl) {
		[refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Refreshing data..."]];
		[refreshControl setEnabled:NO];
	}
	
	// Get any new Wall Images since the last update
	[self getWallImagesSince:_lastImageUpdate];
}

- (void) getWallImagesSince:(NSDate *)lastUpdate
{
    // 1
    // Get the complete list of friend ids
    NSArray *meAndMyFriends = [DataStore instance].fbFriends.allKeys;
    
    // 2
    // Create a PFQuery, Parse Query object
    PFQuery *imageQuery = [PFQuery queryWithClassName:PF_WALL_POST_CLASSNAME];
    [imageQuery orderByAscending:@"createdAt"];
    [imageQuery whereKey:@"updatedAt" greaterThan:lastUpdate];
    [imageQuery whereKey:@"postObjectId" containedIn:meAndMyFriends];
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // 3
        __block NSDate *newLastUpdate = lastUpdate;
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            // 4
            // Go through the returned PFObjects
            for(PFObject *wallImageObject in objects) {
                // 5
                // Get the Facebook User Id of the user that uploaded the image
                PFUser *user = [[DataStore instance].fbFriends objectForKey:wallImageObject[@"postObjectId"]];
                WallImage *wallImage = [[WallImage alloc] init];
                wallImage.objectId = wallImageObject.objectId;
                wallImage.user = user;
                wallImage.createdDate = wallImageObject.updatedAt;
                wallImage.text = wallImageObject[@"text"];
                wallImage.userPicture = [Global getProfileImageFromURL:user[PF_USER_PICTURE]];
//                [[NSOperationQueue pffileOperationQueue] addOperationWithBlock:^ {
//                    wallImage.image = [UIImage imageWithData:[(PFFile *)wallImageObject[@"image"] getData]];
//                    
//                    // Notify - Image Downloaded from Parse
//                    [[NSNotificationCenter defaultCenter] postNotificationName:N_ImageDownloaded object:nil];
//                }];
                if ([wallImageObject.updatedAt compare:newLastUpdate] == NSOrderedDescending) {
                    newLastUpdate = wallImageObject.updatedAt;
                }
                
                [[DataStore instance].wallImages insertObject:wallImage atIndex:0];
                [[DataStore instance].wallImageMap setObject:wallImage forKey:wallImage.objectId];
            };
            [self.tableView reloadData];
        }
        
        [ProgressHUD dismiss];
        
        if (self.refreshControl) {
            NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [_dateFormatter stringFromDate:[NSDate date]]];
            [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:lastUpdated]];
            [self.refreshControl endRefreshing];
        }
        // Callback
//        if ([delegate respondsToSelector:@selector(commsDidGetNewWallImages:)]) {
//            [delegate commsDidGetNewWallImages:newLastUpdate];
//        }
    }];
}


#pragma mark UI Actions from Storyboard

- (IBAction) uploadPressed:(id)sender
{
	// Seque to the Image Uploader
	[self performSegueWithIdentifier:@"UploadImage" sender:self];
}


- (void) imageDownloaded:(NSNotification *)notification {
	//[self.tableView reloadData];
}

- (void) commentUploaded:(NSNotification *)notification
{
	//[self refreshImageWall:nil];
}

- (void) imageUploaded:(NSNotification *)notification
{
	//[self refreshImageWall:nil];
}

+ (void) addComment:(NSString *)comment toWallImage:(WallImage *)wallImage
{
    // Save the new Comment to the Wall Image
    PFObject *wallImageCommentObject = [PFObject objectWithClassName:PF_WALL_COMMENT_CLASSNAME];
    wallImageCommentObject[@"comment"] = comment;
    wallImageCommentObject[@"postObjectId"] = [[PFUser currentUser] objectForKey:PF_USER_PICTURE];
    wallImageCommentObject[@"user"] = [PFUser currentUser].username;
    
    // Set the object id for the associated WallImage
    wallImageCommentObject[@"imageObjectId"] = wallImage.objectId;
    
    // Save the comment to Parse
    [wallImageCommentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // Notify that the Comment has been uploaded, using NSNotificationCenter
        //[[NSNotificationCenter defaultCenter] postNotificationName:N_CommentUploaded object:nil];
    }];
}

- (void) commsDidGetNewWallImages:(NSDate *)updated {
	// Update the update timestamp
	_lastImageUpdate = updated;
	
	// Get the latest WallImageComments from Parse
	[self getWallImageCommentsSince:_lastCommentUpdate];
	
	// Refresh the table data to show the new images
	[self.tableView reloadData];
}

- (void) getWallImageCommentsSince:(NSDate *)lastUpdate
{
    // Get all the Wall Image object Ids
    NSArray *wallImageObjectIds = [DataStore instance].wallImageMap.allKeys;
    
    // Execute the PFQuery to get the Wall Image Comments for all the Wall Images
    PFQuery *commentQuery = [PFQuery queryWithClassName:PF_WALL_COMMENT_CLASSNAME];
    [commentQuery orderByAscending:@"createdAt"];
    [commentQuery whereKey:@"updatedAt" greaterThan:lastUpdate];
    [commentQuery whereKey:@"imageObjectId" containedIn:wallImageObjectIds];
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // In the callback, we will return the latest update timestamp with this request.
        // Default to the current last update.
        __block NSDate *newLastUpdate = lastUpdate;
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageCommentObject, NSUInteger idx, BOOL *stop) {
                // Look up the User's Facebook Graph User
                PFUser *user = [[DataStore instance].fbFriends objectForKey:wallImageCommentObject[@"postObjectId"]];
                
                // 1
                // Look up the Wall Image
                WallImage *wallImage = [[DataStore instance].wallImageMap objectForKey:wallImageCommentObject[@"imageObjectId"]];
                
                // Add the Comment to the Wall Image
                if (wallImage) {
                    WallImageComment *wallImageComment = [[WallImageComment alloc] init];
                    wallImageComment.user = user;
                    wallImageComment.createdDate = wallImageCommentObject.updatedAt;
                    wallImageComment.comment = wallImageCommentObject[@"comment"];
                    wallImageComment.userPicture = [Global getProfileImageFromURL:user[PF_USER_PICTURE]];
                    if ([wallImageCommentObject.updatedAt compare:newLastUpdate] == NSOrderedDescending) {
                        newLastUpdate = wallImageCommentObject.updatedAt;
                    }
                    
                    //2
                    [wallImage.comments addObject:wallImageComment];
                }
            }];
        }
        
        // Callback
        if ([self respondsToSelector:@selector(commsDidGetNewWallImageComments:)]) {
            [self commsDidGetNewWallImageComments:newLastUpdate];
        }
    }];	
}

- (void) commsDidGetNewWallImageComments:(NSDate *)updated {
	// Update the update timestamp
	_lastCommentUpdate = updated;
	
	// Refresh the image wall table
	[self.tableView reloadData];
	
	// Update the refresh control if we have one
	if (self.refreshControl) {
		NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [_dateFormatter stringFromDate:[NSDate date]]];
		[self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:lastUpdated]];
		[self.refreshControl endRefreshing];
	}
}



#pragma mark Table View Datasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	// One section per WallImage
	return [DataStore instance].wallImages.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// One row per WallImage comment
//	WallImage *wallImage = ([DataStore instance].wallImages[section]);
//	return wallImage.comments.count + 2; // Add a row for the New Comment cell
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 5;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//	// The header View is actually a UITableViewCell defined in the Storyboard
//	static NSString *ImageCellIdentifier = @"ImageCell";
//    ImageWallTableImageCell *imageCell = (ImageWallTableImageCell *)[tableView dequeueReusableCellWithIdentifier:ImageCellIdentifier];
//    
//	WallImage *wallImage = ([DataStore instance].wallImages[section]);
//    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:wallImage.text attributes:@{ NSParagraphStyleAttributeName : text_style}];
//	imageCell.lblPost.attributedText = attrText;
//	
//	// Add the user's profile picture to the header cell
//    //[imageCell.profilePicture setImage:[Global getProfileImage:wallImage.user[@"fbId"]]];
//    [imageCell setPictureWithFBId:wallImage.user[@"fbId"]];
//	
//    return imageCell;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
        return 130;
    else
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
//    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Get the WallImage from the indexPath.section
	WallImage *wallImage = ([DataStore instance].wallImages[indexPath.section]);
	
//    if(indexPath.row == 0) {
//         The header View is actually a UITableViewCell defined in the Storyboard
    static NSString *ImageCellIdentifier = @"ImageCell";
    ImageWallTableImageCell *imageCell = (ImageWallTableImageCell *)[tableView dequeueReusableCellWithIdentifier:ImageCellIdentifier];
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:wallImage.text attributes:@{ NSParagraphStyleAttributeName : text_style}];
    imageCell.lblPost.attributedText = attrText;
    
    // Add the user's profile picture to the header cell
    //[imageCell.profilePicture setImage:[Global getProfileImage:wallImage.user[@"fbId"]]];
    [imageCell setPictureWithImage:wallImage.userPicture];
    imageCell.userObjectId = wallImage.user.objectId;

    return imageCell;
//    }
    
//	if (indexPath.row >= wallImage.comments.count+1) {
//        
//		// If this is the last row in the section, create a NewCommentCell
//        static NSString *NewCommentCellIdentifier = @"NewCommentCell";
//		ImageWallTableNewCommentCell *newCommentCell = (ImageWallTableNewCommentCell *)[tableView dequeueReusableCellWithIdentifier:NewCommentCellIdentifier];
//		
//		// Set the WallImage on the cell so that new comments can be associated with the correct WallImage
//		newCommentCell.wallImage = wallImage;
//		
//		return newCommentCell;
//	}
//	
	// Get the associated WallImageComment from the indexPath.row
//    static NSString *CommentCellIdentifier = @"CommentCell";
//    ImageWallTableCommentCell *commentCell = (ImageWallTableCommentCell *)[tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier];
//     NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:wallImage.text attributes:@{ NSParagraphStyleAttributeName : text_style}];
////	WallImageComment *wallImageComment = wallImage.comments[indexPath.row-1];
//    [commentCell setPictureWithImage:wallImage.userPicture];
//	//[commentCell.profilePicture setImage:[Global getProfileImage:wallImageComment.user[@"fbId"]]];
//	[commentCell.comment setAttributedText:attrText];
//    return commentCell;
}

@end
