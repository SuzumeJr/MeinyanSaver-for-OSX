//
//  NSCharactar.m
//  MeinyanSaver
//
//  Created by SuzumeJr on 2013/06/27.
//  Copyright (c) 2013 SuzumeJr. All rights reserved.
//

#import "NSCharactar.h"
#import "NSCharFrame.h"

///キャラクター行動パターン定数
typedef enum : int
{
    CHAR_WAIT          = 0,     ///<    待機
    CHAR_LEFT_TO_RIGHT = 1,     ///<    左から右
    CHAR_RIGHT_TO_LEFT = -1,    ///<    右から左
} CHAR_PATTERN;

/**
 *  キャラクタークラス
 *  @details    1キャラ自体となるオブジェクト
 *              行動パターンは下記のとうり
 *              +ランダムに設定された時間待機
 *              +右から登場するか左から登場するかをランダムで決定
 *              +画面右端および左端から登場し反対側へ歩いていく
 *              +反対側へたどり着いたら初回に戻って繰り返し
 *  @note       複数生成すればクローンがｗ雑魚キャラとかそうなんだろねｗ
 *              あと、コレに色々パターンなんか加えていけば色々なモノ出来るかと
 */
@interface NSCharactar()
{
@private
    ///キャラクター環境情報
    NSRect          _rectScreen;
    
    /**
     *  キャラクタのアニメーションパターン画像
     *  @details    各NSArraryオブジェクト変数内にはNSCharFrameクラスを格納しておく
     *  @see        NSCharFrame
     */
    ///@{
    NSArray*        _aImgLeftToRight;   ///<左から右
    NSArray*        _aImgRightToLeft;   ///<右から左
    
    NSInteger       _iLeftToRightFrames;    ///<左から右のフレーム数
    NSInteger       _iRightToLeftFrames;    ///<右から左のフレーム数
    ///@}
    
    ///キャラクター情報
    ///@{
    CHAR_PATTERN    _ePattern;  ///<行動パターン
    NSPoint         _point;     ///<現在位置
    NSInteger       _iFrame;    ///<現在表示パターンフレーム
    NSInteger       _iWait;     ///<待ち時間
    NSRect          _rectChar;  ///<キャラパターンの基本サイズ
    ///@}
}
@end

@implementation NSCharactar

/**
 *  初期化イメージ作成
 *  @param  rectScreen  [I/-]   表示先の画面情報
 *  @param  aL2RPt      [I/-]   左から右に移動するキャラパターンデータ
 *  @param  aR2LPt      [I/-]   右から左に移動するキャラパターンデータ
 *  @retval TRUE    初期設定処理完了
 *  @retval FALSE   キャラパターンデータが不正
 */
-(BOOL)initData:(NSRect)rectScreen L2RPattern:(NSArray *)aL2RPt R2LPattern:(NSArray *)aR2LPt
{
    BOOL bResult = FALSE;
    
    //格納しておく
    _rectScreen = rectScreen;   //画面情報
    
    _aImgLeftToRight = aL2RPt;  //左から右パターン
    _aImgRightToLeft = aR2LPt;  //右から左パターン
    
    _iLeftToRightFrames = [_aImgLeftToRight count];
    _iRightToLeftFrames = [_aImgRightToLeft count];
    
    bResult = ( _iRightToLeftFrames>0 && _iLeftToRightFrames>0 );
    
    return bResult;
}

/**
 *  待機パターンの設定
 *  @param  [I/-]   iWait   待機時間を設定
 *  @return 処理結果
 *  @note   現在戻り値はTRUE固定
 */
-(BOOL)setWaitPattern:(NSInteger)iWait
{
    //基本の待機処理を行っておく
    [self setWaitPattern];
    
    //引数の時間を加算しておく
    _iWait += iWait;
    
    return TRUE;
}

/**
 *  アクションメソッド
 *  @details    キャラクタの行動を処理する
 *  @return キャラクターが有効か無効を返す
 *  @retval TRUE    キャラクターは有効
 *  @retval FALSE   キャラクターは無効
 *  @note   現在はTRUEとかしか返さないです。
 *          まぁ後々ソース流用する場合、キャラが退場とか死亡消滅した場合はFALSE返すコトになるかとｗ
 */
-(BOOL)Action
{
    BOOL bResult = TRUE;
    BOOL bEnable = FALSE;
    
    ///行動パターン別処理
    switch( _ePattern )
    {
        case CHAR_WAIT:
            bEnable = [self actionWaite];
            break;
            
        case CHAR_LEFT_TO_RIGHT:
            bEnable = [self actionLeftToRight];
            break;
        
        case CHAR_RIGHT_TO_LEFT:
            bEnable = [self actionRightToLeft];
            break;
    }
    ///行動パターンがまだ有効か
    if( !bEnable )
    {
        ///有効でない場合は次パターンを設定
        [self setNextPattern];
    }
    
    return bResult;
}

/**
 *  待機行動処理
 */
-(BOOL)actionWaite
{
    BOOL bResult = FALSE;
    
    //待ち時間をカウントダウン
    if( 0 < --_iWait )
    {
        bResult = TRUE;
    }
    
    return bResult;
}

/**
 *  左から右移動処理
 *  @details
 *  @return     パターン処理がまだ有効か無効かを返す
 *  @retval     TRUE    パターン処理は有効(まだ画面内)
 *  @retval     FALSE   パターン処理が無効(画面右端外へ出たため)
 */
-(BOOL)actionLeftToRight
{
    BOOL bResult = FALSE;
    
    //次フレーム算出(繰り返しなためフレーム数超えたらリセットして0に)
    if( ++_iFrame >= _iLeftToRightFrames ) _iFrame = 0;
    
    //次フレームデータ取得
    NSCharFrame* frameDt = (NSCharFrame*)[_aImgLeftToRight objectAtIndex:_iFrame];
    
    //描画位置算出
    _point.x += frameDt->ptMove.x;
    
    //スクリーンから完全に消えていないかチェック
    if( (_rectScreen.size.width + frameDt->img.size.width ) > _point.x )
    {
        //描画処理
        [self drawChar:frameDt->img drowPoint:_point ];
        bResult = TRUE;
    }
    
    return bResult;
}

/**
 *  右から左移動処理
 *  @return パターン処理がまだ有効か無効かを返す
 *  @retval TRUE    パターン処理は有効(まだ画面内)
 *  @retval FALSE   パターン処理が無効(画面左端外へ出たため)
 */
-(BOOL)actionRightToLeft
{
    BOOL bResult = FALSE;

    //次フレーム算出(繰り返しなためフレーム数超えたらリセットして0に)
    if( ++_iFrame >= _iRightToLeftFrames ) _iFrame = 0;
    
    //次フレームデータ取得
    NSCharFrame* frameDt = (NSCharFrame*)[_aImgRightToLeft objectAtIndex:_iFrame];
    
    //描画位置算出
    _point.x += frameDt->ptMove.x;
    
    //画面から完全に消えていないかチェック
    if( (_point.x + frameDt->img.size.width) > 0 )
    {
        //描画処理
        [self drawChar:frameDt->img drowPoint:_point ];
        bResult = TRUE;
    }
    
    return bResult;
}

/**
 *  次キャラクターパターンの設定
 *  @return 次パターンが設定されたかどうか
 */
-(BOOL)setNextPattern
{
    BOOL bResult = FALSE;
    
    //現在の行動パターンから次の行動パターン決定
    switch( _ePattern )
    {
        case CHAR_WAIT:
            //ランダムで右か左かを振り分け
            if( random() % 2 )
            {
                bResult = [self setLeftToRightPattern];
            }
            else
            {
                bResult = [self setRightToLeftPattern];
            }
            break;
        
        case CHAR_LEFT_TO_RIGHT:
        case CHAR_RIGHT_TO_LEFT:
            //移動アクション時は一回待機処理させる
            bResult = [self setWaitPattern];
            break;
    }
    
    return bResult;
}

/**
 *  待機パターン設定
 *  @return TRUE固定
 */
-(BOOL)setWaitPattern
{
    BOOL bResult = TRUE;
    
    _ePattern = CHAR_WAIT;  //行動パターンを設定
    
    //次回登場までの待機時間を設定(テキトー[適当とテキトーは違うのだ])
    _iWait = ( random() % 5 );
    
    return bResult;
}

/**
 *  左から右移動パターン設定
 *  @return TRUE固定
 */
-(BOOL)setLeftToRightPattern
{
    BOOL bResult = TRUE;
    
    _ePattern = CHAR_LEFT_TO_RIGHT; //行動パターンを設定
    _iFrame = 0;                    //初回表示フレーム番号セット
    
    NSCharFrame* frameDt = (NSCharFrame*)[_aImgRightToLeft objectAtIndex:_iFrame];
    
    _point.x = -frameDt->img.size.width;                //画面左端設定(0だと画像が表示されちゃうのでパターン画像分マイナス)
    _point.y = [self RandomCharPointY:frameDt->img];    //高さのY軸はランダム
    
    return bResult;
}

/**
 *  右から左移動パターン設定
 *  @return TRUE固定
 */
-(BOOL)setRightToLeftPattern
{
    BOOL bResult = TRUE;
    
    _ePattern = CHAR_RIGHT_TO_LEFT; //行動パターンを設定
    _iFrame = 0;                    //初回表示フレーム番号セット
    
    //パターンで使用するフレーム画像データ設定
    NSCharFrame* frameDt = (NSCharFrame*)[_aImgRightToLeft objectAtIndex:_iFrame];
    
    //表示位置設定
    _point.x = _rectScreen.size.width;                  //画面右端
    _point.y = [self RandomCharPointY:frameDt->img];    //高さのY軸はランダム
    
    return bResult;
}

/**
 *  手抜きY軸表示位置乱数
 *  @param      img [I/-]  表示する画像オブジェクト
 *  @return     ランダム生成されたY軸表示位置
 *  @details    画面の大きさを考慮つつ高さとなるY軸位置の数値をランダムで返します。
 *  @note       きっちり画面に収まるカンジではなく画像がハミ出て少しでも表示されてるならOKにしてありますが
 *              画像の端って透明部分ばっかだからなんも表示されてない場合もあるよなぁｗ(だから手抜きなんです)
 */
-(CGFloat)RandomCharPointY:(NSImage*)img
{
    CGFloat rangeY = _rectScreen.size.height + img.size.height;
    
    CGFloat pointY = (float)( random() % (long)rangeY ) - img.size.height;
    
    return pointY;
}

/**
 *  キャラクタの描画
 *  @param  img [I/-]   描画画像
 *  @param  pt  [I/-]   描画位置
 */
-(void)drawChar:(NSImage*)img drowPoint:(NSPoint)pt
{
    [img drawAtPoint:pt fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 ];
}
@end
