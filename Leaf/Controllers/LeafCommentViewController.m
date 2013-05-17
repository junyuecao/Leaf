//
//  LeafCommentViewController.m
//  Leaf
//
//  Created by roger on 13-4-19.
//  Copyright (c) 2013年 Mobimtech. All rights reserved.
//

#import "RFHUD.h"

#import "LeafCommentViewController.h"
#import "LeafCommentModel.h"
#import "LeafCommentCell.h"
#import "LeafNavigationBar.h"
#import "LeafLoadingView.h"
#import "LeafMenuBar.h"
#import "LeafStatusBarOverlay.h"

#define kLeafCommentCellTag 1001

@interface LeafCommentViewController ()
{
    NSString* _articleId;
    LeafCommentModel *_commentModel;
    UITableView *_table;
    LeafLoadingView *_loading;
    LeafMenuBar *_menuBar;
    LeafStatusBarOverlay *_mr;
}

@property (nonatomic, retain) NSString *articleId;

@end

@implementation LeafCommentViewController
@synthesize articleId = _articleId;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_commentModel release], _commentModel = nil;
    [_articleId release], _articleId = nil;
    [_menuBar release], _menuBar = nil;
    [_mr release], _mr = nil;
    _table = nil;
    
    [super dealloc];
}


#pragma mark - LeafCommentModel Notification Stuff

- (void)loadCommentSuccess:(NSNotification *)notification
{
    [self hideLeafLoadingView];
    LeafCommentModel *model = (LeafCommentModel *)notification.object;
    if (model) {
        [_table reloadData];
    }
}

- (void)loadCommentFailed:(NSNotification *)notification
{
    [self hideLeafLoadingView];
     
    RFHUD *hud = [[RFHUD alloc] initWithFrame:kLeafWindowRect];
    [hud setHUDType:RFHUDTypeError andStatus:@"评论加载失败"];
    [hud show];
    [hud release];
}

- (void)loadCommentCanceled:(NSNotification *)notification
{
    [self hideLeafLoadingView];
}

#pragma mark - 
#pragma mark - loading view

- (void)showLeafLoadingView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    CGPoint center = _loading.center;
    center.y = (CGHeight(self.view.frame) - CGHeight(_loading.frame)/2.0f);
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _loading.center = center;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}


- (void)hideLeafLoadingView
{
    CGPoint center = _loading.center;
    center.y = CGHeight(self.view.frame) + CGHeight(_loading.frame)/2.0f;
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         _loading.center = center;
                     }
                     completion:^(BOOL finished) {
                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                     }];
    
}

#pragma mark -
#pragma mark - Handle NavigationBar Events

- (void)backClicked:(id)sender
{
    [self dismissViewControllerWithOption:LeafAnimationOptionHorizontal
                               completion:^{
                                   [self cancel];
                               }];
}

- (void)refreshClicked:(id)sender
{
    [self loadData:_articleId];
}

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    LeafNavigationBar *bar = [[LeafNavigationBar alloc] init];
    [bar addLeftItemWithStyle:LeafNavigationItemStyleBack target:self action:@selector(backClicked:)];
    [bar addRightItemWithStyle:LeafNavigationItemStyleRefresh target:self action:@selector(refreshClicked:)];
    [_container addSubview:bar];
    [bar release];
      
    __block LeafCommentViewController *controller = self;
    [self enablePanRightGestureWithDismissBlock:^(void){
        [controller cancel];
    }];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, 320.0f, CGRectGetHeight(self.view.frame) - 44.0f)];
    tableView.dataSource = self;
    tableView.delegate = self;
    [_container addSubview:tableView];
    _table = tableView;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_table setBackgroundColor:kLeafBackgroundColor];
    [tableView release];
    
    LeafLoadingView *loading = [[LeafLoadingView alloc] initWithFrame:CGRectMake(0.0f, CGHeight(self.view.frame), CGWidth(self.view.frame), 30.0f)];
    _loading = loading;
    [_container addSubview:_loading];
    [loading release];

    _menuBar = [[LeafMenuBar alloc] initWithFrame:_container.bounds];
    _menuBar.hidden = YES;
    _menuBar.delegate = (NSObject<LeafMenuBarDelegate> *)self;
    [_container addSubview:_menuBar];
    
    _mr = [[LeafStatusBarOverlay alloc] init];
    
    _commentModel = [[LeafCommentModel alloc] init];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(loadCommentSuccess:)
                          name:kLeafLoadCommentSuccess
                        object:_commentModel];
    
    [defaultCenter addObserver:self
                      selector:@selector(loadCommentFailed:)
                          name:kLeafLoadCommentFailed
                        object:_commentModel];
    [defaultCenter addObserver:self
                      selector:@selector(loadCommentCanceled:)
                          name:kLeafLoadCommentCanceled
                        object:_commentModel];

    
}

- (void)loadData:(NSString *)articleId
{
    self.articleId = articleId;
    [_commentModel load:articleId];
    [self showLeafLoadingView];
    
}

- (void)cancel
{
    [_commentModel cancel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - UITableViewDataSource UITableViewDelegate 

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _commentModel.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = indexPath.row;
    NSString *comment = @"";
    if (index >= 0 && index < _commentModel.dataArray.count) {
        LeafCommentData *data = [_commentModel.dataArray objectAtIndex:index];
        comment = data.comment;
    }
    
    return [LeafCommentCell heightForComment:comment];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"LeafCommentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        LeafCommentCell *commentCell = [[LeafCommentCell alloc] init];
        commentCell.tag = kLeafCommentCellTag;
        [cell.contentView addSubview:commentCell];
        [commentCell release];
    }
     LeafCommentCell *commentCell = (LeafCommentCell *)[cell.contentView viewWithTag:kLeafCommentCellTag];
    LeafCommentData *data = [_commentModel.dataArray safeObjectAtIndex:indexPath.row];
    
    
    if (data) {
        NSString *name = data.name;
        if (!data.name || [data.name isEqualToString:@""]) {
            name = @"匿名";
        }

        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", data.time, @"time", data.comment, @"comment", nil];
        [commentCell loadData:dict];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect rectInTableView = [tableView rectForRowAtIndexPath:indexPath];
    CGRect rectInSuperView = [tableView convertRect:rectInTableView toView:tableView.superview];
    
    CGFloat minY = CGRectGetMinY(rectInSuperView);
    CGFloat offsetY = 0.0f;
    if (minY > 80.0f) {
        offsetY = minY - 80.0f;
        _menuBar.type = LeafMenuBarArrowTypeDown;
    }
    else{
        CGFloat maxY = CGRectGetMaxY(rectInSuperView);
        offsetY = maxY - 11.0f;
        _menuBar.type = LeafMenuBarArrowTypeUp;

    }
    
    _menuBar.offsetY = offsetY;
    [_menuBar show];

}

#pragma mark -
#pragma mark - LeafMenuBarDelegate

- (void)menuBar:(LeafMenuBar *)menubar didClickedItemWithType:(LeafMenuBarItemType)type
{
    switch (type) {
        case LeafMenuBarItemTypeUp:
            [_mr postMessage:@"谢谢您的参与" dismissAfterDelay:1.0f];
            break;
            
        default:
            break;
    }
}

@end
