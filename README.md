# TLPicker
一款只需几行代码就可以轻松实现选择功能的便利工具, 是对UIKit常用工具UIPickerView和UIDatePicker的一种便利封装.

## 使用场景
选择日期, 单列选择, 多列选择, 多级联动选择(例如选择省市区)都只需要几行代码即可实现.

试想当你想要自己实现多级联动的PickerView时, 你需要为此维护你的数据模型在PickerView每一组件需要显示的内容, 并在选择后根据每一组件的下标再次从源数据模型中拿到你想要的内容, 此过程十分繁琐也不美观.

在TLPicker中只要给出需要显示和返回的一段"keyPath"即可完成上述的工作.

## KeyPath
TLPicker会尝试根据传入的KeyPath解析Data(Array, Dictionary或实体类都可), 如果解析失败会从控制台打印出失败信息和原因.

### KeyPath指令
'->' 代表往下解析
'.'代表取出当前数组元素的某个值作为目标(ps: '.'的个数代表picker组件的个数, 所以使用'.'指令时当前所在的位置必须是Array)

example: @"->provices.name->cities.name"


## 使用

'''

TLPicker *picker = [TLPicker pickDateForView:self.view initialDate:[NSDate date] selectedBlock:^BOOL(BOOL isCancel, NSDate *date) {
        if (isCancel) {
            return YES;
        }
        
        NSLog(@"选择的日期是: %@", date);
        return YES;
    }];
    [picker show:YES];
'''
