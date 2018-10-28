# BC架构探索之路

做iOS也有些年头了，最近把项目核心模块的架构重新设计了一番，这里做一些记录。

首先，我们要对基础的设计模式有一定的认知。这些基础的设计模式，便是**MVC**、**MVVM**、**VIPER**。

## MVC、MVVM

关于 MVC ，斯坦福的 Paul 老头有一张经典的图示，相信大部分iOSer都看过：

![avator](https://coding.net/u/joeyxu/p/Resources/git/raw/master/mvc.png)

当有多个模块时，我们需要有多个 MVC 互相配合：

![avator](https://coding.net/u/joeyxu/p/Resources/git/raw/master/MVCs%20working%20together.png)

可以看到，多个模块之间的交互都是通过 Controller 层。以上就是 MVC 的概览，那么 MVVM 是什么样的呢？

MVVM 是 Model-View-ViewModel 的缩写。其实在 MVC 的基础上再稍进一步，把 Controller 与 View 之间的数据传递过程独立出来，封装成一个模块，叫做 ViewModel ，这就成了 MVVM 了。在 MVVM 的基础上，通常还会使用双向绑定技术，使得 View 和 ViewModel 之间可以自动同步。

## VIPER

![avator](https://coding.net/u/joeyxu/p/Resources/git/raw/master/viper.png)

VIPER ，全称 View-Interactor-Presenter-Entity-Router 。这是另一种细分 MVC 而得到的架构。从上图可以看到， VIPER 实际上是将 MVC 中的 Controller 细化为了三个模块，即 Presenter、Interactor、Router 。 Entity 负责数据持久化， Interactor 负责业务相关的逻辑计算等， Presenter 则负责将业务数据传递给 View ，也负责处理 View 的事件。大部分 View 的事件是交由逻辑侧 interactor 处理，在 interactor 处理完后会触发必要的 UI 刷新。跳转相关的 View 事件则交由 Router 处理。

可以看到， VIPER 和 MVVM 并不矛盾，我们可以在 MVVM 的基础上继续细化得到 VIPER ， ViewModel 相关的逻辑放在 Presenter 中即可。

同样，当有多个模块时，我们需要有多个 VIPER 互相配合。

## 纵览

可以看到传统架构的进化过程： MVC -> MVVM -> VIPER 。这是一个对架构不断细化的过程。在工程实践中，我们的业务采用什么架构，需要根据业务的形态和频繁变动的模块而定。

不知大家有没有发现，以上所述的架构解决的是单个业务模块内的职责划分问题，并没有解决如何将多个业务模块组合在一起的问题。即多个 MVC 或者 多个 VIPER 之间如何配合？实践中我们发现：

- 通过对 MVC 的进一步细分，可以从单个业务模块的角度上缓解 MVC 中 Controller 中心化所导致的 massive view controller 的问题，但对于有众多业务模块的 Controller 来说， massive view controller 依然得不到解决，即中心化的 Controller 需要做大量胶水层的工作，管理各个子 Controller 。
- 用好传统架构，可以保证单个业务模块内的代码的可复用性，但并不能避免业务之间的互相影响。简单说，就是修改业务 A 的 bug 时，可能会给业务 B 引入 bug 。
- ...

归根结底，就是因为没有一种更为宏观的组合模块的架构体系。正是为了解决如何将多个业务模块组合在一起的问题，我设计了一套 BC 的架构体系。

## BC

BC ，全称 BusinessController ，是一种为解决业务模块耦合和管理问题而生的架构体系。

为了表明 BC 的思想和实践效果，这里我以 UIViewController 的瘦身为例进行阐述。众所周知， iOS 开发最让人头痛的问题之一就是 UIViewController 的代码过于庞大，难以维护。更有网友戏谑称 MVC 为 massive view controller 。

#### Massive View Controller

iOS 系统默认以 UIViewController 扮演 Controller 的角色，推出一个界面就是 push 一个 UIViewController 。因此作为一个界面的总管， UIViewController 管理着各个子模块，也包揽了众多的边界模糊的工作。每当我们需要新增一个业务功能，首先就要找到对应的 UIViewController ，再在其中进行编码，如下述代码所示：

```
@interface ViewController ()

@property (nonatomic, assign) BOOL A_LogicFlag;
@property (nonatomic, assign) BOOL B_LogicFlag;
... (keep adding flags)

@property (nonatomic, strong) A_ControllerClass *A_Controller;
@property (nonatomic, strong) B_ControllerClass *B_Controller;
... (keep adding modules)

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.A_Controller = [A_ControllerClass new];
    [self.view addSubview:self.A_Controller.view];
    __weak typeof(self) weakSelf = self;
    [self.A_Controller sendRequestOnCompletion:^(BOOL success){
        weakSelf.A_LogicFlag = YES;
    }];
    
    self.B_Controller = [B_ControllerClass new];
    self.B_Controller.delegate = self.A_Controller;
    
    ... (keep adding code)
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    [self.B_Controller sendRequestOnCompletion:^(BOOL success){
        weakSelf.B_LogicFlag = YES;
    }];
    
    ... (keep adding code)
}

@end
```

以上代码已经把每一个业务逻辑封装为一个个模块，然后在 UIViewController 中管理和维系各个业务模块间的关系，这是我们日常工作中最常见的代码。很明显，随着业务模块的不断增加，整个 UIViewController 的代码量将会无上限的增加。并且各个业务都在这个 UIViewController 中修改代码，很容易互相引入bug，产生耦合。

如果有细心的读者，会发现这其中还有时序问题。怎么讲？假设现在我们有一个模块 C ，我们想要做一个小改动：将 A 模块的初始化时机放在 C 模块的数据请求返回成功后。这是个很简单的改动，只需将 A 模块的初始化工作放入 C 模块的数据请求返回的 completion block 里：

```
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.C_Controller = [C_ControllerClass new];
    __weak typeof(self) weakSelf = self;
    [self.C_Controller sendRequestOnCompletion:^(BOOL success){
        weakSelf.A_Controller = [A_ControllerClass new];
        [weakSelf.view addSubview:weakSelf.A_Controller.view];
        [weakSelf.A_Controller sendRequestOnCompletion:^(BOOL success){
            weakSelf.A_LogicFlag = YES;
        }];
    }];
    
    self.B_Controller = [B_ControllerClass new];
    self.B_Controller.delegate = self.A_Controller;
    
    ... (keep adding code)
}
```
若不仔细看看，难以发现以上代码已经有了 bug 。因为我们延迟了 A_Controller 的初始化，所以在 B_Controller 设置 delegate 时，写入的 A_Controller 是 nil 。这就是时序依赖， B_Controller 在设置 delegate 时，要求 A_Controller 已经完成了初始化。看似这种时序问题在所难免，其实不然。在 BC 架构中，我将描述一种解决该时序问题的方案。

另外，由于 coder 在 VC 中有着极高的自由度，所以当 coder 在做一些小特性时，会直接把代码写在 VC 中。大家为省事不再去为小功能独立创建模块，这样 VC 中的代码会更加混乱不堪。

- 无限增长的代码量
- 鱼龙混杂的耦合关系
- 复杂的时序问题
- 过度自由引入的混乱
- ...

让我们来看看 BC 的架构体系如何来解决这些问题。

#### BC 实现

我们让 UIViewController 只负责持有和维护一个业务模块（ businessController ）的数组，其并不关心数组中每个业务模块的具体实现。我们定义一个 businessController 的基类，或者协议。这里我们以协议为例，定义协议 `BusinessController` 。
```
// Define.h
@protocol BusinessController <NSObject>
@end

// ViewController.h
@interface ViewController : UIViewController
@property (nonatomic, strong) NSMutableArray<id<BusinessController>> *businessControllers;
@end

```

首先，我们希望能够将 View Controller 的状态事件通知给 Business Controller ，而 Business Controller 可以选择性的实现这些事件。所以我们先定义一个协议 `ViewControllerEvents` 。因为是可选择性实现，所以为 optional 。

```
// Define.h
@protocol ViewControllerEvents <NSObject>
@optional
- (void)jx_viewDidLoad;
- (void)jx_viewWillAppear;
- (void)jx_viewDidAppear;
- (void)jx_viewWillDisappear;
- (void)jx_viewDidDisappear;
// ... 其它主框架的事件也可放在这里
@end
```

然后使 `BusinessController` 遵循 `ViewControllerEvents` 协议，这样在 BusinessController 就有了监听 VC 事件的能力，并且可以自动补全这些方法名。

```
// Define.h
@protocol BusinessController <ViewControllerEvents>
@required
// 建立一个vc的弱引用，用于访问vc
@property (nonatomic, weak) ViewController *viewController;
@end
```

接着， VC 需要向业务模块发送这些状态事件。以 `viewWillAppear` 为例，

```
// ViewController.m
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.businessControllers enumerateObjectsUsingBlock:^(id<BusinessController>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(jx_viewWillAppear)]) {
            [obj jx_viewWillAppear];
        }
    }];
}
```

现在，当我们需要新增一个模块 A 时，只需使其遵循 `BusinessController` 协议，一切就像在一个全新的 VC 中编码一样，十分清爽。

```
// BusinessControllerA.m
- (void)jx_viewWillAppear {
    // do some logic request or other business logics ...
}
```

最后，我们只需在 VC 中添加各个业务模块，让整个流程跑通：

```
// ViewController.m
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBusinessControllers:@[[A_ControllerClass new],
                                   [B_ControllerClass new],
                                   [C_ControllerClass new],
                                   ...]];
}
```

至此， VC 中的代码就被我们划分为了许许多多的模块。可是，**业务模块之间，是需要通信的**，那我们又如何解决这个通信问题呢？我们最容易想到的是两种常规的通信方式—— NSNotification 和 delegate 。

首先， NSNotification 是不合适的。这是一种全局通知，整个 APP 都会收到。我们希望的结果是， `ViewController` 实例一中的模块 A 给模块 B 发消息时，不会发送到 `ViewController` 实例二中的模块 B 去。

那我们就用 delegate 吧？—— NO！ 第一，使用 delegate 我们需要不断的去维护那些对象之间的 delegate 关系（即在 VC 中编写 delegate 的依赖关系，`A.delegate = B`），这也会引入 **Massive View Controller** 中提到的时序问题。第二，若是模块 A 的代理事件模块 B 和模块 C 都需要监听，我们还需要将 delegate 做成数组。咦，真够恶心。

所以，我们能否找到一种更好的方式来解决通信问题呢？

这里我提供的解决方案是使用 OC 的消息转发特性（对消息转发不太了解的同学，可以学习一下《Effective Objective-C 2.0》中消息转发的章节）。首先我们创建一个消息中心 `CommunicationCenter` ，一个消息协议 `BusinessControllerConversation` 。让消息中心遵循消息协议，但其内部不实现任何方法，其只做转发，将消息转发给每一个实现了该消息的业务模块（ BC ）。接收消息的 BC 也遵循 `BusinessControllerConversation` 协议。

```
// Define.h
@protocol BusinessControllerConversation <NSObject>
@end

// Define.h
@protocol BusinessController <ViewControllerEvents, BusinessControllerConversation>
@required
// 建立一个vc的弱引用，用于访问vc
@property (nonatomic, weak) ViewController *viewController;
@end

// CommunicationCenter.m
@interface CommunicationCenter : NSObject <BusinessControllerConversation>
// 建立一个vc的弱引用，用于访问vc
@property (nonatomic, weak) ViewController *viewController;
@end

// CommunicationCenter.m
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = anInvocation.selector;
    [self.viewController.businessControllers enumerateObjectsUsingBlock:^(id<BusinessController> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:selector]) {
            [anInvocation invokeWithTarget:obj];
        }
    }];
}
```

接着，我们在 VC 中创建并持有一个消息中心。

```
// ViewController.h
@property (nonatomic, strong) CommunicationCenter *communicationCenter;

// ViewController.m
_communicationCenter = [CommunicationCenter new];
```

这样，当我们的业务模块之间需要通信时，将消息定义在 `BusinessControllerConversation` 中，然后直接向消息中心发送消息即可。例如当前页面的刷新按钮被点击了，但管理刷新按钮的模块并不管当前页面有哪些模块需要刷新，它只管将该消息抛到消息中心。而需要刷新的业务模块，则实现该消息即可。

```
// Define.h
@protocol BusinessControllerConversation <NSObject>
@optional
- (void)msg_refreshButtonClicked;
@end

// B_ControllerClass.m
- (void)refreshBtnClicked {
    [self.viewController.communicationCenter msg_refreshBtnClicked];
}

// A_ControllerClass.m
- (void)msg_refreshBtnClicked {
    // do some business logic ...
}
```

由此，我们实现了单个VC中，模块之间一对多的互相通信。这里值得注意的是，模块 A 和模块 B 的耦合度几乎降至最低。因为 A 和 B 之间互相都不知道对方，不需要设置对方为 delegate ，也不会有建立依赖的时序问题。 BC 都全部面向消息编程，即面向协议编程。

这就是使用 CommunicationCenter 进行统一转发的通信方式所带来的极大好处：消息发送方不需要关心谁接收消息，其只管通知一下某事件发生了。消息接收方也不需要关心谁发送的消息，其只管接收消息做出反应。这样使业务模块间的耦合性降至最低。

不难发现，只要是业务模块 BC 所需要的事件，我们都可以通过 `CommunicationCenter` 进行转发。所以我们让 `CommunicationCenter` 和 `BusinessController` 遵循 `ViewControllerEvents` 协议，这样 `ViewController` 中的状态事件，我们直接抛给 `CommunicationCenter` 即可。状态事件会经过 `CommunicationCenter` 路由至业务 BC 。

```
// ViewController.m
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.communicationCenter jx_viewWillAppear];
}
```

在采用 BC 的架构之后，所有的模块都需要创建 BC ，再也没有随意散落在 VC 中的代码。

至此，我们实现了将 VC 中的业务模块逐一打散，各自为营，也支持业务模块之间的灵活通信。其代码量无限增长的问题、代码糅杂在一起鱼龙混杂的问题等，都得到了解决。

## BC 与传统架构

![avator](https://coding.net/u/joeyxu/p/Resources/git/raw/master/BC_Overview.png)

 BC 设计模式的通信结构如上图所示（ Owner 即文中的 ViewController ）。 Owner 将主流程事件发至消息中心，由消息中心路由至各个 Module 。而各个 Module 之间也通过消息中心转发至其他 Module 。
 
可以看到 BC 和传统的 MVC ， MVVM , VIPER 的关系不是互斥的，是并存的。从 MVC 到 MVVM 到 VIPER 是对架构的不断细化。而 BC 则是提供了一种划分模块的机制。即一个 Module 可以是 Model ，可以是 View ，也可以是包含了 MVC 的一个完整的模块。在使用 MVC ， MVVM ， VIPER 等设计模式时，我们可以同时使用 BC 来帮助我们组织各个模块。通过 BC ，我们将根据不同架构设计的不同模块有机的结合了起来。
