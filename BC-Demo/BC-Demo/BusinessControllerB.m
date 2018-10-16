//
//  BusinessControllerB.m
//  BCDemo
//
//  Created by Joey Xu on 2018/9/30.
//  Copyright © 2018 Joey Xu. All rights reserved.
//

#import "BusinessControllerB.h"
#import "CommunicationCenter.h"

@interface BusinessControllerB ()
@property (nonatomic, strong) UIButton *refreshBtn;
@end

@implementation BusinessControllerB

- (instancetype)init {
    self = [super init];
    if (self) {
        _refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshBtn addTarget:self action:@selector(refreshBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)refreshBtnClicked {
    [self.viewController.communicationCenter msg_refreshBtnClicked];
}

@end
