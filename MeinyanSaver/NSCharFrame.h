//
//  NSCharFrame.h
//  MeinyanSaver
//
//  Created by SuzumeJr on 2013/06/27.
//  Copyright (c) 2013 SuzumeJr. All rights reserved.
//

#import <Foundation/Foundation.h>

///キャラクターパターンフレーム情報
@interface NSCharFrame : NSObject
{
@public
    NSPoint     ptMove;     ///<キャラクタ移動情報
    NSInteger   iWaite;     ///<キャラクタ表示時間カウンタ数
    NSImage*    img;        ///<キャラクタ表示画像
}
@end
