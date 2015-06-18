//
//  CommentsTableViewController.m
//  HackerNews
//
//  Created by Vetrichelvan on 15/06/15.
//  Copyright (c) 2015 Vetrichelvan. All rights reserved.
//

#import "CommentsTableViewController.h"
#import <Firebase/Firebase.h>
#import "StoryTableViewCell.h"
#import "NSDate+TimeAgo.h"

@interface CommentsTableViewController ()
@property (nonatomic, strong) NSMutableArray *temporaryCommentsIds;
@property (nonatomic, strong) NSMutableArray *commentEventRefs;
@end

@implementation CommentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", self.story);
    
    self.title = @"Comments";
    
    self.temporaryCommentsIds = [self.story valueForKey:@"kids"];
    
    for(NSNumber *itemNumber in self.temporaryCommentsIds){
        [self getStoryDataOfItem:itemNumber];
    }
    
    UINib *celllNib = [UINib nibWithNibName:@"StoryTableCellView" bundle:nil] ;
    [self.tableView registerNib:celllNib forCellReuseIdentifier:@"storyCell"];

    
    [self.tableView reloadData];
    
    
        // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)getStoryDataOfItem:(NSNumber *)itemNumber{
    
    //[[Crashlytics sharedInstance] crash];
    
    NSString *urlString = [NSString stringWithFormat:@"https://hacker-news.firebaseio.com/v0/item/%@",itemNumber];
    
    //    NSLog(@"%@", itemNumber);
    
    Firebase *storyDescriptionRef = [[Firebase alloc] initWithUrl:urlString];
    
    [self.commentEventRefs addObject:storyDescriptionRef];
    //[storyDescriptionRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
    [storyDescriptionRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        //NSDictionary *responseDictionary = snapshot.value;
        
        
        if(snapshot.value != [NSNull null]){
            NSLog(@"%@", snapshot.value);
            //            [self.tableView reloadData];
        }
        
        
        
        
        
    } withCancelBlock:^(NSError *error) {
        
    }
     ];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    //NSLog(@"%@", snapshot.value);
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    //    static NSString *CellIdentifier = @"storyCell";
    //    StoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //
    
    
    StoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"storyCell" forIndexPath:indexPath];
    
    if (cell==nil) {
        
        NSArray* storyObject = [[NSBundle mainBundle] loadNibNamed:@"CurrentOffersInfoView" owner:self options:nil];
        
        cell = [storyObject firstObject];
    }
    
    
    
    
    // Get data from the array at position of the row
    NSDictionary *story = self.story;
    
    //Get the Time interval from when the story is posted
    NSTimeInterval timeSince = [[story valueForKey:@"time"] doubleValue];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970: timeSince];
    NSString *ago = [date timeAgo];
    //NSLog(@"Output is: \"%@\"", ago);
    
    //Get Comments count
    NSMutableArray *commentArray = [story valueForKey:@"kids"];
    NSUInteger commentCount = [commentArray count];
    NSString *commentCountText = [NSString stringWithFormat:@"%@",  @(commentCount)];
    //NSLog (@"Number of elements in array = %lu", [commentArray count]);
    
    //Get the HostName
    NSString *urlString = [story valueForKey:@"url"];
    NSURL* url = [NSURL URLWithString:[story valueForKey:@"url"]];
    NSString* reducedUrl = [NSString stringWithFormat:
                            @"%@",url.host];
    //NSLog(@"Output is: \"%@\"", reducedUrl);
    if([story valueForKey:@"deleted"]){
    } else {
        
        
        // Apply the data to each row
        cell.titleLabel.text = [story valueForKey:@"title"];
        cell.authorWithTimeLabel.text = [NSString stringWithFormat:@"by %@, %@", [story valueForKey:@"by"], ago];
        cell.commentLabel.text = [NSString stringWithFormat:@"%@", commentCountText];
        cell.scoreLabel.text = [NSString stringWithFormat:@"%@", [story valueForKey:@"score"]];
        cell.sourceLabel.text = urlString.length > 0 ? reducedUrl : @"";
        cell.typeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", [story valueForKeyPath:@"type"]]];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.titleLabel.numberOfLines = 0;
        [cell.titleLabel sizeToFit];
        
    }
    //[HUD hide:YES];
    [cell layoutIfNeeded];
    [cell setNeedsLayout];
    
    //NSLog(@"Output is: \"%@\"", cell.titleLabel);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *story = self.story;
    NSString* text = [story valueForKey:@"title"];
    NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:text attributes:
                                             @{ NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    
    //its not possible to get the cell label width since this method is called before cellForRow so best we can do
    //is get the table width and subtract the default extra space on either side of the label.
    CGSize constraintSize = CGSizeMake(300 - 30, MAXFLOAT);
    
    CGRect rect = [attributedString boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    //NSLog(@"Output is: \"%d\"", rect.size.height);
    
    //Add back in the extra padding above and below label on table cell.
    rect.size.height = rect.size.height + 70;
    
    //if height is smaller than a normal row set it to the normal cell height, otherwise return the bigger dynamic height.
    
    return rect.size.height;
    //return 95;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
