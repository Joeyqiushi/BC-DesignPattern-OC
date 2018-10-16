//
//  ViewControllerDefine.h
//  BCDemo
//
//  Created by Joey Xu on 2018/9/30.
//  Copyright © 2018 Joey Xu. All rights reserved.
//

#ifndef ViewControllerDefine_h
#define ViewControllerDefine_h

@class ViewController;

@protocol ViewControllerEvents <NSObject>
@optional
- (void)jx_viewDidLoad;
- (void)jx_viewWillAppear;
- (void)jx_viewDidAppear;
- (void)jx_viewWillDisappear;
- (void)jx_viewDidDisappear;
// ... 其它主框架的事件也可放在这里
@end

@protocol BusinessControllerConversation <NSObject>
@optional
- (void)msg_refreshBtnClicked;
@end

@protocol BusinessController <ViewControllerEvents, BusinessControllerConversation>

@required
// 建立一个vc的弱引用，用于访问vc
@property (nonatomic, weak) ViewController *viewController;

@end

#endif /* ViewControllerDefine_h */
