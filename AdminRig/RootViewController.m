//
//  ViewController.m
//  AnalyticRig
//
//  Created by John Bogil on 12/18/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "RootViewController.h"
@import FirebaseDatabase;
@import Firebase;

@interface RootViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) FIRDatabaseReference *groupsRef;
@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *currentUserRef;
@property (strong, nonatomic) FIRDatabaseReference *currentUsersGroupsRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) NSString *userID;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.rootRef = [[FIRDatabase database] reference];
    self.groupsRef = [self.rootRef child:@"groups"];
    self.usersRef = [self.rootRef child:@"users"];
}

- (void)fetchFollowCountForGroupKey:(NSString *)groupKey {
    
    [[[self.groupsRef child:groupKey]child:@"followers"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value == [NSNull null]) {
            return ;
        }
        NSLog(@"%@ FOLLOWERS COUNT: %lu", groupKey,[snapshot.value count]);
        
    }];
}

- (void)fetchTotalUserCount {
    [self.usersRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value == [NSNull null]) {
            return ;
        }
        NSLog(@"TOTAL USER COUNT: %lu", [snapshot.value count]);
        
    }];
}

- (void)fetchFollowCountForAllGroups {
    
    NSMutableArray *groupKeysArray = @[].mutableCopy;
    
    [self.groupsRef  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value == [NSNull null]) {
            return ;
        }
        
        [groupKeysArray addObjectsFromArray:snapshot.value];
        
        for (NSString *groupKey in groupKeysArray) {
            [[[self.groupsRef child:groupKey]child:@"followers"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                if (snapshot.value == [NSNull null]) {
                    return ;
                }
                NSLog(@"%@ FOLLOWERS COUNT: %lu", groupKey,[snapshot.value count]);
                
            }];
        }
    }];
}

#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Fetch Group Counts";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 0) {
        [self fetchFollowCountForAllGroups];
        [self fetchTotalUserCount];
    }
}

@end
