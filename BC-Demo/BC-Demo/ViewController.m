//
//  ViewController.m
//  BCDemo
//
//  Created by Joey Xu on 2018/9/30.
//  Copyright © 2018 Joey Xu. All rights reserved.
//

#import "ViewController.h"
#import "Define.h"
#import "CommunicationCenter.h"
#import "BusinessControllerA.h"
#import "BusinessControllerB.h"
#import "BusinessControllerC.h"

@interface ViewController ()
@end

@implementation ViewController

#pragma mark - Life Cycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _businessControllers = [NSMutableArray new];
        _communicationCenter = [CommunicationCenter new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init BCs and add them to _businessControllers
    [self addBusinessControllers:@[[BusinessControllerA new],[BusinessControllerB new]]];
    
    [self.communicationCenter jx_viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.communicationCenter jx_viewWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.communicationCenter jx_viewWillDisappear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.communicationCenter jx_viewDidAppear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.communicationCenter jx_viewDidDisappear];
}

#pragma mark - Business Controllers

- (void)addBusinessController:(id<BusinessController>)businessController {
    if (businessController && ![_businessControllers containsObject:businessController]) {
        [_businessControllers addObject:businessController];
        businessController.viewController = self;
    }
}

- (void)addBusinessControllers:(NSArray<id<BusinessController>> *)businessControllers {
    __weak typeof(self) weakSelf = self;
    [businessControllers enumerateObjectsUsingBlock:^(id<BusinessController> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf addBusinessController:obj];
    }];
}

- (void)removeBusinessController:(id<BusinessController>)businessController {
    if (businessController) {
        businessController.viewController = nil;
        [_businessControllers removeObject:businessController];
    }
}

- (void)removeBusinessControllers:(NSArray<id<BusinessController>> *)businessControllers {
    [businessControllers enumerateObjectsUsingBlock:^(id<BusinessController> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeBusinessController:obj];
    }];
}

@end
