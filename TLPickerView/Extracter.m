//
//  Extracter.m
//  StarPlanForTeacher
//
//  Created by Ian on 16/6/1.
//  Copyright © 2016年 Guangzhou Shiny Read Education Technology  Shiny Read Education. All rights reserved.
//

#import "Extracter.h"
#import "TLUtil.h"


NS_ENUM(NSInteger, ExtracterOrder) {
    ExtracterOrderDoNothing = 0,
    ExtracterOrderInto = 1,
    ExtracterOrderExtract = 2,
};


@implementation Extracter

- (instancetype)init {
    if (self = [super init]) {
        _content = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithValue:(NSString *)value {
    if (self = [self init]) {
        self.value = value;
    }
    return self;
}


+ (Extracter *)parseEntity:(id)entity keyPath:(NSString *)keyPath {
    
    if (!entity) {
        DLog(@"Extracter \n 数据解析错误 , entity为空");
        return nil;
    }
    
    if (!keyPath || keyPath.length<=0) {
        DLog(@"Extracter \n 数据解析错误 , keyPath为空");
        return nil;
    }
    
    Extracter *parseModel = [Extracter new];
    if ([parseModel isRationalKeyPath:keyPath inEntity:entity]) {
        [parseModel _parseEntity:entity keyPath:keyPath];
        return parseModel;
    }
    
    return nil;
}


- (void)_parseEntity:(id)entity keyPath:(NSString *)keyPath {
    
    NSScanner *scanner = [NSScanner scannerWithString:keyPath];
    NSString *key;
    enum ExtracterOrder order = ExtracterOrderDoNothing;
    
    //提取出该阶段的行为与操作的key
    NSInteger orderLength = 0;
    while (key == nil) {
        
        if ([scanner scanString:@"." intoString:nil]) {
            if (order == ExtracterOrderDoNothing) {
                order = ExtracterOrderExtract;
                orderLength = 1;
            } else {
                key = [keyPath substringWithRange:NSMakeRange(orderLength, scanner.scanLocation-orderLength - 1)];
            }
        } else if ([scanner scanString:@"->" intoString:nil]) {
            if (order == ExtracterOrderDoNothing) {
                order = ExtracterOrderInto;
                orderLength = 2;
            } else {
                key = [keyPath substringWithRange:NSMakeRange(orderLength, scanner.scanLocation-orderLength - 2)];
            }
        } else if ([scanner isAtEnd]) {
            key = [keyPath substringFromIndex:orderLength];
            break;
        } else {
            scanner.scanLocation += 1;
        }
    }
    
    //对上次行为提取出的order做相应的行为
    switch (order) {
        case ExtracterOrderInto:
            [self _parseEntity:entity[key]
                       keyPath:[keyPath substringFromIndex:orderLength + key.length]];
            break;
        case ExtracterOrderExtract: {
            
            NSMutableArray<Extracter *> *contents = [NSMutableArray new];
            NSArray *array = entity;
            
            for (id object in array) {
                
                id value = object[key];
                if ([value isKindOfClass:[NSNumber class]]) {
                    value = [value stringValue];
                }
                Extracter *extrancter = [[Extracter alloc] initWithValue:value];
                [extrancter _parseEntity:object
                                 keyPath:[keyPath substringFromIndex:orderLength + key.length]];
                [contents addObject:extrancter];
            }
            self.content = contents;
        }
            break;
        default:
            break;
    }
}

/*
 * keyPath使用前的安全检验
 */
- (BOOL)isRationalKeyPath:(NSString *)keyPath inEntity:(id)entity {
    
    if (![keyPath hasPrefix:@"."] && ![keyPath hasPrefix:@"->"]) {
        DLog(@"Extracter keyPath解析错误, 必须以操作指令.或->开头");
        return NO;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:keyPath];
    NSString *key;
    NSString *arrayKeyName;
    NSString *currentKeyPath = keyPath;
    NSUInteger lastOrderLocation = 0;
    enum ExtracterOrder order = ExtracterOrderDoNothing;
    
    while (![scanner isAtEnd]) {
        
        if ([scanner scanString:@"." intoString:nil]) {
            if (order == ExtracterOrderDoNothing) {
                order = ExtracterOrderExtract;
            } else {
                scanner.scanLocation -= 1;
                key = [currentKeyPath substringWithRange:NSMakeRange(lastOrderLocation, MAX(scanner.scanLocation - lastOrderLocation, 0))];
            }
            lastOrderLocation = scanner.scanLocation;
        } else if ([scanner scanString:@"->" intoString:nil]) {
            
            if (order == ExtracterOrderDoNothing) {
                order = ExtracterOrderInto;
            } else {
                scanner.scanLocation -= 2;
                key = [currentKeyPath substringWithRange:NSMakeRange(lastOrderLocation, MAX(scanner.scanLocation - lastOrderLocation, 0))];
            }
            lastOrderLocation = scanner.scanLocation;
        } else {
            scanner.scanLocation += 1;
            
            if ([scanner isAtEnd]) {
                key = [currentKeyPath substringWithRange:NSMakeRange(lastOrderLocation, MAX(scanner.scanLocation - lastOrderLocation, 0))];
            }
        }
        
        
        if (key) {
            switch (order) {
                case ExtracterOrderInto: {
                    if ([entity isKindOfClass:[NSArray class]]) {
                        DLog(@"Extracter 数据解析错误 , -> 指令不能作用于数组");
                        return NO;
                    }
                    
                    id value = [entity valueForKey:key];
                    if (!value) {
                        DLog(@"Extracter 数据解析错误 , 不存在该key: %@", key);
                        return NO;
                    } else {
                        arrayKeyName = key;
                        entity = value;
                    }
                }
                    break;
                case ExtracterOrderExtract: {
                    NSArray *array = entity;
                    if (![array isKindOfClass:[NSArray class]]) {
                        DLog(@"Extracter 数据解析错误 , .%@ 指令的对象不为数组", key);
                        return NO;
                    }
                    
                    if (array.count <= 0) {
                        DLog(@"Extracter 数据解析错误 , %@ 数组为空无法提取 %@ 的值", arrayKeyName, key);
                        return NO;
                    }
                    
                    id object = array[0];
                    id value = [object valueForKey:key];
                    
                    if (!value) {
                        DLog(@"Extracter 数据解析错误 , 不存在该key: %@", key);
                        return NO;
                    } else if (![value isKindOfClass:[NSString class]]
                               && ![value isKindOfClass:[NSNumber class]]) {
                        DLog(@"Extracter 数据解析错误 , key: %@ 类型不是NSString或者NSNumber", key);
                        return NO;
                    }
                    
                    entity = object;
                }
                    break;
                default:
                    break;
            }
            
            key = nil;
            order = ExtracterOrderDoNothing;
        }
    }
    
    return YES;
}



@end
