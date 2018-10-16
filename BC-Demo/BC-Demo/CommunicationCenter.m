//
//  CommunicationCenter.m
//  BCDemo
//
//  Created by Joey Xu on 2018/9/30.
//  Copyright © 2018 Joey Xu. All rights reserved.
//

#import "CommunicationCenter.h"
#import "Define.h"

@implementation CommunicationCenter

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = anInvocation.selector;
    [self.viewController.businessControllers enumerateObjectsUsingBlock:^(id<BusinessController> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:selector]) {
            [anInvocation invokeWithTarget:obj];
        }
    }];
}

@end
