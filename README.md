# TLPicker
一款只需几行代码就可以轻松实现选择功能的便利工具, 是对UIKit常用工具UIPickerView和UIDatePicker的封装.
并简化了实现多级联动选择器的配置流程.
## 使用场景
选择日期, 单列选择, 多列选择, 多级联动选择(例如选择省市区)都只需要几行代码即可实现.

## 关于多级联动选择器
试想当你想要自己实现多级联动的PickerView时, 你需要为此从源数据中提取出在PickerView每一组件需要显示的内容, 并在用户选择完后根据每一组件的下标再次从源数据中逐层拿到你想要的内容, 此过程十分繁琐也不美观.

而使用TLPicker只需要给出需要显示和返回的一段"keyPath"即可完成上述的工作.


## 使用

###### 日期选择器
```objc
TLPicker *picker = [TLPicker pickDateForView:self.view initialDate:[NSDate date] selectedBlock:^BOOL(BOOL isCancel, NSDate *date) {
        if (isCancel) {
            return YES;
        }
        
        //do something
        
    }];
[picker show:YES];
```


BOOL返回值的结果决定了在执行block后是否隐藏选择器



###### 非联动的线性结构的选择器
```objc
[[TLPicker pickLinearData:data
                      forView:self.view selectedBlock:^BOOL(BOOL isCancel, NSArray<NSString *> *selectedTitles, NSArray<NSNumber *> *indexs) {
                          
                          //do something
                          
                          return YES;
                          
                      }] show:YES];
```



###### 多级联动选择器
```
[[TLPicker pickEntity:entity
             inputKeyPath:@"->provinces.name->cities.name->areas.name"
            outputKeyPath:@"->provinces.id->cities.id->areas.id"
                  forView:self.view
            selectedBlock:^BOOL(BOOL isCancel, NSArray<NSString *> *results, NSArray<NSNumber *> *indexs) {
                
                //do something
                
                return YES;
                
            }] show:YES];
```

## KeyPath
TLPicker会尝试根据传入的KeyPath解析Data(Array, Dictionary或实体类都可)

#### KeyPath指令
> '->'  代表往下解析 

> '.'  代表取出当前数组元素的某个值作为目标   (ps: '.'的个数代表picker组件的个数, 所以使用'.'指令时当前所在的位置必须是Array) 


## 注意

keyPath仅是一段字符串, 没法在编译时给予足够的操作错误提示, 但可以在调试时查看控制台的错误信息找到问题所在

## 系统要求

该项目最低支持 iOS 6.0 和 Xcode 7.0。


## 许可证

TLPicker 使用 MIT 许可证，详情见 LICENSE 文件。

