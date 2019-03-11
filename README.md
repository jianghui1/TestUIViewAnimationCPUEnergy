前段时间一直有个别用户反馈 app 耗电量很快，手机发烫。问了下设备信息，判断不应该是设备过时的原因，自己手头测试也没有发现什么问题。

直到今天，亲眼看到 app 界面反应特别卡顿，而且手机发烫确实很严重。最后经过排查，发现是跑马灯导致的。

跑马灯使用 `UIView` 动画实现的，由于一直循环，导致控件没有释放，动画一直持续，最后 CPU 占用过多，手机耗电巨大。

下面根据测试用例说明下这个问题。测试用例可以在[这里](https://github.com/jianghui1/TestUIViewAnimationCPUEnergy)下载。

首先测试用例中有三个控制器 `ViewController` `FirstViewController` `SecondViewController`，`ViewController` 中有一个按钮可以跳转到 `FirstViewController`，`FirstViewController` 中有一个按钮可以跳转到 `SecondViewController`。`FirstViewController` 中再添加一个红色 `view` ，并写代码使其做 `frame` 移动的 `UIView` 动画。

动画代码的不同，会造成不一样的结果，分情况讨论一下：

1. 一般情况下，没有什么问题：

    
        - (void)startAction
        {
            CGFloat x = 0;
            if (self.redView.frame.origin.x != 375) {
                x = 375;
            }
            [UIView animateWithDuration:5 animations:^{
                self.redView.frame = CGRectMake(x, self.redView.frame.origin.y, self.redView.frame.size.width, self.redView.frame.size.height);
            } completion:^(BOOL finished) {
                if (finished) {
                    [self startAction];
                }µ
            }];
        }
    
这种情况下，不会有什么 cpu 电量上的问题，只是当从 `SecondViewController` 返回到 `FirstViewController` 时动画会结束。app 运行情况如图。

![正常](https://github.com/jianghui1/TestUIViewAnimationCPUEnergy/blob/master/正常.png?raw=true)

2. 为了使返回的时候，动画继续进行，对代码进行了部分改造：


    - (void)startAction
    {
        CGFloat x = 0;
        if (self.redView.frame.origin.x != 375) {
            x = 375;
        }
        [UIView animateWithDuration:5 animations:^{
            self.redView.frame = CGRectMake(x, self.redView.frame.origin.y, self.redView.frame.size.width, self.redView.frame.size.height);
        } completion:^(BOOL finished) {
    //        if (finished) {
                [self startAction];
    //        }
        }];
    }
    
这样的话，返回的时候动画就不会停止，但是，问题也就出现了。此时的 app 运行状态如图。

![非正常](https://github.com/jianghui1/TestUIViewAnimationCPUEnergy/blob/master/不正常.png?raw=true)

可以看到这时候 CPU 使用率已经超出了负载，电量耗费很大，而且 `FirstViewController` 没有释放掉。

3. 为了解决以上两种问题，继续对代码进行改造。

    
     - (void)startAction
    {
        CGFloat x = 0;
        if (self.redView.frame.origin.x != 375) {
            x = 375;
        }
        [UIView animateWithDuration:5 animations:^{
            self.redView.frame = CGRectMake(x, self.redView.frame.origin.y, self.redView.frame.size.width, self.redView.frame.size.height);
        } completion:^(BOOL finished) {
            if (finished) {
                [self startAction];
            }
        }];
    }
    
    - (void)viewWillAppear:(BOOL)animated
    {
        [self startAction];
    }
    
app运行状态如图。

![解决方案](https://github.com/jianghui1/TestUIViewAnimationCPUEnergy/blob/master/解决方案.png?raw=true)

这时，页面返回时动画能够继续进行，`FirstViewController` 正常释放，CPU 电量使用也正常。
