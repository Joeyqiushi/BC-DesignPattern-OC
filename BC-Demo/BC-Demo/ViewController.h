//
//  ViewController.h
//  BCDemo
//
//  Created by Joey Xu on 2018/9/30.
//  Copyright © 2018 Joey Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"

@class CommunicationCenter;

@interface ViewController : UIViewController
@property (nonatomic, strong) NSMutableArray<id<BusinessController>> *businessControllers;
@property (nonatomic, strong) CommunicationCenter *communicationCenter;
@end

