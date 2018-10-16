//
//  BusinessControllerB.h
//  BCDemo
//
//  Created by Joey Xu on 2018/9/30.
//  Copyright © 2018 Joey Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"

NS_ASSUME_NONNULL_BEGIN

@interface BusinessControllerB : NSObject <BusinessController>
@property (nonatomic, weak) ViewController *viewController;
@end

NS_ASSUME_NONNULL_END
