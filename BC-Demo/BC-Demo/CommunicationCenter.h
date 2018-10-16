//
//  CommunicationCenter.h
//  BCDemo
//
//  Created by Joey Xu on 2018/9/30.
//  Copyright © 2018 Joey Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommunicationCenter : NSObject <BusinessControllerConversation, ViewControllerEvents>
// 建立一个vc的弱引用，用于访问vc
@property (nonatomic, weak) ViewController *viewController;
@end

NS_ASSUME_NONNULL_END
