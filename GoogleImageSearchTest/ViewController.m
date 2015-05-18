//
//  ViewController.m
//  GoogleImageSearchTest
//
//  Created by Wei Zhang on 5/17/15.
//  Copyright (c) 2015 weizhang. All rights reserved.
//

#import "ViewController.h"
#import "ImageResultCell.h"
#import "ImageResult.h"
#import "ImageSearchRequest.h"
#import "ServiceManger.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+Project.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *searchHistoryTable;

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) NSMutableArray *searchHistories;
@property (nonatomic, strong) NSMutableArray *resultImages;

@property (nonatomic, strong) NSString *currentQuery;

@property (nonatomic, strong) id keyboardShowingObserver;
@property (nonatomic, strong) id keyboardHidingObserver;


@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLayouts];
    [self setupKeyboardAppearanceNotificationObservers];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchHistoryTable.dataSource = self;
    self.searchHistoryTable.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardShowingObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardHidingObserver];
}

#pragma mark - Properties
- (NSMutableArray *)resultImages {
    if (!_resultImages) {
        _resultImages = [NSMutableArray array];
    }
    return _resultImages;
}

- (NSMutableArray *)searchHistories {
    if (!_searchHistories) {
        _searchHistories = [NSMutableArray array];
    }
    return _searchHistories;
}

#pragma mark - Internal methods
- (void)setupLayouts {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat edge = screenWidth * 0.3;
    CGSize itemSize = CGSizeMake(edge, edge);
    CGFloat spacing = (screenWidth - 3 * edge) / 4;
    
    self.flowLayout.itemSize = itemSize;
    self.flowLayout.minimumInteritemSpacing = spacing;
    self.flowLayout.minimumLineSpacing = spacing;

}

- (void)setupKeyboardAppearanceNotificationObservers {
    __weak typeof(self) weakSelf = self;
    self.keyboardShowingObserver
    = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                        object:nil
                                                         queue:[NSOperationQueue mainQueue]
                                                    usingBlock:
       ^(NSNotification *note) {
           NSDictionary *userInfo = note.userInfo;
           CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
           weakSelf.searchHistoryTable.contentInset = UIEdgeInsetsMake(0, 0, keyboardEndFrame.size.height, 0);
       }];
    
    self.keyboardHidingObserver
    = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                        object:nil
                                                         queue:[NSOperationQueue mainQueue]
                                                    usingBlock:
       ^(NSNotification *note) {
           weakSelf.searchHistoryTable.contentInset = UIEdgeInsetsZero;
       }];
}

- (void)startSearchingWithQuery:(NSString *)query {
    [self dismissSearchingContext];
    if ( ! [query isEqualToString:self.currentQuery]) {
        [self searchImagesWithQuery:query];
    }
}

- (void)dismissSearchingContext {
    [self.searchBar resignFirstResponder];
    [self.view bringSubviewToFront:self.collectionView];
}

#pragma mark - Data related
- (void)searchImagesWithQuery:(NSString *)query {
    self.currentQuery = query;
    [self.resultImages removeAllObjects];
    [self.collectionView reloadData];
    ImageSearchRequest *request = [ImageSearchRequest defaultRequestWithQuery:query];
    __weak typeof(self) weakself = self;
    [[ServiceManger sharedManger] searchImagesWithRequest:request completion:^(NSArray *imageResults, NSError *error) {
        if (imageResults) {
            ViewController *strongSelf = weakself;
            if (strongSelf) {
                [strongSelf.resultImages addObjectsFromArray:imageResults];
                [strongSelf.collectionView reloadData];
            }
        }
    }];
}

- (void)startLoadingNextPage {
    [[ServiceManger sharedManger] loadMoreImages];
}

#pragma mark - CollecitonView Delegates
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.resultImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger itemIndex = indexPath.item;
    ImageResultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageResultCell" forIndexPath:indexPath];
    ImageResult *imageResult = self.resultImages[itemIndex];
    [cell.resultImageView setImageWithURL:imageResult.tbURL placeholderImage:[UIImage cellPlaceholderImage]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger itemIndex = indexPath.item;
    NSInteger imageCount = [self.resultImages count];
    
    if (imageCount > 0 && itemIndex == [self.resultImages count] - 4) {
        [self startLoadingNextPage];
    }
}

#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchHistories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    NSString *searchHistory = self.searchHistories[indexPath.row];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    cell.textLabel.text = searchHistory;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *searchHistory = self.searchHistories[indexPath.row];
    self.searchBar.text = searchHistory;
    [self startSearchingWithQuery:searchHistory];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Search history";
}

#pragma mark - UISearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.view bringSubviewToFront: self.searchHistoryTable];
    [self.searchHistoryTable reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchStr = searchBar.text;
    searchStr = [searchStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    searchStr = [searchStr lowercaseString];
    if (searchStr.length > 0) {
        if ( ! [self.searchHistories containsObject:searchStr]) {
            [self.searchHistories addObject:searchStr];
        }
        [self startSearchingWithQuery:searchStr];
    }
}

@end
