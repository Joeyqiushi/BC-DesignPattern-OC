//
//  BusinessControllerC.h
//  BCDemo
//
//  Created by Joey Xu on 2018/10/16.
//  Copyright © 2018 Joey Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"

NS_ASSUME_NONNULL_BEGIN

@interface BusinessControllerC : NSObject <BusinessController>
@property (nonatomic, weak) ViewController *viewController;
@end

NS_ASSUME_NONNULL_END
