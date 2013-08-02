//
//  MeinyanSaverView.m
//  MeinyanSaver
//
//  Created by SuzumeJr on 2013/06/22.
//  Copyright (c) 2013 SuzumeJr. All rights reserved.
//

#import "MeinyanSaverView.h"
#import "NSCharactar.h"
#import "NSCharFrame.h"

@interface MeinyanSaverView()
///@nameスクリーンセーバー設定用の宣言
///@{
- (IBAction)closeOptionWindow:(id)sender;   ///<設定完了用の閉じるボタンが押された場合のアクション
- (IBAction)inputPersons:(id)sender;        ///<テキスト入力で表示人数の設定を変更した場合のアクション
- (IBAction)chengePersons:(id)sender;       ///<スライダーで表示人数の設定を変更した場合のアクション
- (IBAction)inputInterval:(id)sender;       ///<テキスト入力で表示速度を変更した場合のアクション
- (IBAction)chengeInterval:(id)sender;      ///<スライダーで表示速度を変更した場合のアクション
- (IBAction)chengeAlpha:(id)sender;         ///<スライダーで残像濃度を変更した場合のアクション
- (IBAction)inputAlpha:(id)sender;          ///<テキスト入力で残像濃度を変更した場合のアクション
///@}
@end
 
@implementation MeinyanSaverView
{
@private
    
    IBOutlet id configSheet;        ///<スクリーンセーバー設定オプションのMSWindowオブジェクトを格納するOutlet
    ///@name    スクリーンセーバ設定ウインド内コントロール用Outlet
    ///@{
    IBOutlet NSTextField*   _txtPersons;    ///<表示人数
    IBOutlet NSTextField*   _txtInterval;   ///<表示速度
    IBOutlet NSTextField*   _txtAlpha;      ///<残像濃度
    IBOutlet NSSlider*      _sldPerson;     ///<表示人数
    IBOutlet NSSlider*      _sldInterval;   ///<表示速度
    IBOutlet NSSlider*      _sldAlpha;      ///<残像濃度
    ///@}
    
    NSColor*    _clrBack;           ///<背景塗りつぶしカラー
    
    ///@name    メイニャンアニメーションデータ群
    ///@{
    NSDictionary*   _dicImages;         ///<アニメイーション用画像(NSImage)を格納、Keyはファイル名(拡張子除く)
    NSArray*        _aImgMeinyanLeft;   ///<左向きキャラパターン(NSCharaFrame)を格納
    NSArray*        _aImgMeinyanRight;  ///<右向きキャラパターン(NSCharaFrame)を格納
    NSArray*        _aChras;            ///<メイニャン(NSCharactar)の人数分を格納
    ///@}
    
    ///@name    スクリーンセーバーの設定値
    ///@{
    NSInteger   _persons;   ///<    メイニャンの人数
    NSInteger   _interval;  ///<    アニメーション速度
    NSInteger   _alpha;     ///<    残像濃度
    ///<    残像濃度
    ///@}
}
/**
 *  初期処理メソッド
 *  @param  frame       スクリーンセーバする画面サイズなんですかね？
 *  @param  isPreview   プレビューで起動かどうかをOSX側が設定して通知してくる
 *  @return 初期化処理が完了した自分自身を返す(OSXで管理してもらうため？)
 *  @note   初期化したい内容があるときはココに記述
 *  @note   Xcode側で自動生成されたオーバーライドメソッド
 */
- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self)
    {
        //設定を読み込み
        [self LoadSettingValue];
        
        //タイマ的インターバル処理の間隔を設定(sec)
        [self setAnimationTimeInterval:( 11.0f - (float)_interval ) / 10.0f ];
    }
    return self;
}

/**
 *  アニメーション開始
 *  @note   アニメーション開始前に呼び出される
 */
- (void)startAnimation
{
    [super startAnimation];
    
    //乱数初期化
    srandom((unsigned int)time(NULL));
    
    //イメージ画像読み込み
    [self LoadImgPaturn];
}

/**
 *  アニメーション停止
 *  @details    アニメーション停止時に呼び出される。
 *  @note       ユーザーがマウスを動かしたりする場合など
 *  @note       Xcode側で自動生成されたオーバーライドメソッド
 */
- (void)stopAnimation
{
    [super stopAnimation];
}

/**
 *  描画メソッド
 *  @param  [I/-]   rect    スクリーンセーバする画面のサイズ情報？
 *  @note   drawRectを実装すると、スクリーンセーバーが起動する前に画面全体を白の縞模様で塗りつぶしてくれるらしい
 *          最初にdrawRectが呼ばれて、その後animateOneFrameが繰り返し呼ばれるらしいから初回だけの描画処理はココ？
 *          startAnimationと比べて描画準備出来ている前か後かの違いなのかねぇ？
 */
- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

/**
 *  アニメーションメソッド
 *  @details    スクリーンセーバー起動中に定期的に呼び出されるメソッド
 *              -   呼び出される感覚はsetAnimationTimeIntervalメソッドで設定した間隔で呼び出される
 *              -   スクリーンセーバーでアニメーション処理をする場合はこのオーバーライドされているこのメソッドに処理を記述する
 *              -   呼び出されている時点でスクリーンセーバーの画面であるNSViewオブジェクトにはフォーカスが当たった状態(lockfocus済み）になっているので注意
 *  @note       setAnimationTimeIntervalメソッドでの設定はinitWithFrameメソッド内で設定処理が行われている場合が多い
 *  @note       Xcode側で自動生成されたオーバーライドメソッド
 */
- (void)animateOneFrame
{
    [self AnimePaturn];
}

/**
 *  スクリーンセーバーの設定有無
 *  @return スクリーンセーバーの設定オプションの有無
 *  @retval YES 設定オプション有り
 *  @retval NO  設定オプション無し
 *  @note       OSXのシステム環境設定にある[デスクトップとスクリーンセーバー]にある
 *              スクリーンセーバーの[スクリーンセーバーのオプション...]ボタンを
 *              このメソッドの戻り値を元にアクティブか、非アクティブかを判断しているような気がする
 *  @note       Xcode側で自動生成されたオーバーライドメソッド
 *              -   自動生成時、戻り値はNO
 */
- (BOOL)hasConfigureSheet
{
    return YES; //ヘッダコメントにもあるようにスクリーンセーバーオプションが無ければ、戻り値はNOにしておく
}

/**
 *  設定ウインド取得
 *  @return     スクリーンセーバー設定オプションウインドとなるNSWindowオブジェクトを返す
 *  @retval     NSWindowオブジェクト  スクリーンセーバー設定オプションウインドとなるNSWindowオブジェクト
 *  @retval     nil                 スクリーンセーバー設定オプションが無い場合
 *  @details    スクリーンセーバーの設定ウインドを表示したいタイミングにOSX側が呼び出してくるメソッド
 *              -   設定用のウインドがある場合は設定ウインド(NSWindowオブジェクト)を戻り値として返す
 *              -   設定ウインドが無い場合はnilを返す(hasConfigureSheetメソッド側で判っているから呼び出されないとは思うケド・・・)
 *  @see        hasConfigureSheet
 *  @attention  InterfaceBuilder側でNSWindowのプロパティでカテゴリ？ConstrosのClose,Resize,Minimizeのチェックは全て外しておくコト
 *  @note       OSXのシステム環境設定にある[デスクトップとスクリーンセーバー]から
 *              スクリーンセーバーの[スクリーンセーバーのオプション...]ボタンが押された場合などに呼び出される
 *  @note       Xcode側で自動生成されたオーバーライドメソッド
 *              -   自動生成時、戻り値はnil
 */
- (NSWindow*)configureSheet
{
    //既に設定ウインドオブジェクトが生成されているかチェック
    //  -   システム環境設定からのスクリーンセーバーのプレビュー中はスクリーンセーバーも起動状態で
    //      何度も[スクリーンセーバーのオプション...]ボタンが押される場合を考えると初回つくっとけば
    //      次回からは使い回せばOK
    if(!configSheet)
    {
        //SettingWindow.xlbで定義したモノをself(MeinyanSaverView)とバンドルする
        [NSBundle loadNibNamed:@"SettingWindow" owner:self];
        //バンドルさせるとインスタンスの_configSheet変数へオブジェクトがセットされる
        
        //各コントロールへ値を設定
        //表示人数
        _txtPersons.integerValue = _persons;
        _sldPerson.integerValue = _txtPersons.integerValue;
        
        //表示速度
        _txtInterval.integerValue = _interval;
        _sldInterval.integerValue = _txtInterval.integerValue;
        
        //残像濃度
        _txtAlpha.integerValue = _alpha;
        _sldAlpha.integerValue = _txtAlpha.integerValue;
    }
    
//    NSLog(@"**configureSheet**");
//    NSLog(@"Persons=%d",(int)_persons);
//    NSLog(@"Interval=%d",(int)_interval);
//    NSLog(@"Alpha=%d",(int)_alpha);
    
    return configSheet;
}

//自作メソッド
/**
 *  アニメーション処理
 */
-(void)AnimePaturn
{
    NSRect rectScr = [self frame];
    rectScr.origin.x = 0;
    rectScr.origin.y = 0;
    
    //画面消し込み（塗りつぶし）
    [_clrBack set];
    [NSBezierPath fillRect:rectScr];
    
    //キャラクタ描画処理
    for( NSCharactar* meinyan in _aChras )
    {
        [meinyan Action];
    }
}

/**
 *  アニメーション画像読み込み
 *  @return     TRUE固定
 *  @details    リソースからアニメーションに使用する画像データを読み込み処理出来るよう準備する
 *  @return TRUE固定
 */
-(BOOL)LoadImgPaturn
{    
    //塗りつぶし背景色設定
    _clrBack =[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:(10.0f - (float)_alpha ) / 10.0f ];
    
    //リソースを取得
    NSBundle* bundle =[NSBundle bundleForClass: [self class]];
    
    //画像データの読み込み
    _dicImages = [self LoadImages:bundle listName:@"CharFrameImg" ];
    //パターンデータの読み込み
    _aImgMeinyanLeft = [self LoadCharFrame:bundle listName:@"CharL2RPattern" images:_dicImages ];
    _aImgMeinyanRight = [self LoadCharFrame:bundle listName:@"CharR2LPattern" images:_dicImages ];
    
    //キャラデータの生成
    _aChras = [self CreateMeinyans:_persons];
    
    return TRUE;
}

/**
 *  @アニメーションのパターン画像の取得
 *  @param  bundle  リソースデータ
 *  @retval NSArrayオブジェクト   取得した画像(NSImage)が格納されたNSArrayオブジェクト
 *  @retval nil                 画像の取得に失敗
 *  @note       下記の画像フォーマットは読み込めたのを確認
 *              -   TIFF    OSXプレビューでTIFF(アルファ有り)を作成
 *              -   PNG     WindowsのPhotoShopCS6(64Bit)にて作成
 *  @attention  画像に解像度情報があるとpointでサイズ管理されるので、pixelをpointの数値と一緒にしたい場合は画面解像度の72dpiに設定して画像ファイルを作成すること
 */
-(NSDictionary*)LoadImages:(NSBundle*)bundle listName:(NSString*)sName
{
    NSMutableDictionary* dicImages = [NSMutableDictionary dictionary];    //取得画像を格納
    
    //plistを読み込み
    NSString* sPlist = [bundle pathForResource:sName ofType:@"plist"];
    
    //NSArrayへ取り込み
    NSArray* aList = [NSArray arrayWithContentsOfFile:sPlist];

    //リスト画像の読み込み
    for( NSString* sName in aList)
    {
        //リソース内の画像ファイルパスを取得
        NSString* sPath = [bundle pathForResource:sName ofType: @"png"];  //ファイル名と拡張子は大文字、小文字そのままに記述
        //画像を取得
        NSImage* img = [[NSImage alloc] initWithContentsOfFile: sPath];
        //名前とキーとして画像データを格納
        [dicImages setObject:img forKey:sName];
    }
    
    return [dicImages copy];
}

/**
 *  アニメーションパターンのフレーム情報読み込み
 *  @param  bundle  [I/-]   アニメーションパターンのフレーム情報があるリソースオブジェクト
 *  @param  sName   [I/-]   1アニメーションパターンのフレーム情報(plist形式)のファイル名を指定(拡張子は不要)
 *  @param  aImages [I/-]   使用するであろう画像が格納されているNSDictionaryオブジェクト
 *  @return キャラクタの１フレーム毎の情報を納めたNSCharaFrmeオブジェクトがフレーム順に格納されたNSArrayオブジェクト
 */
-(NSArray*)LoadCharFrame:(NSBundle*)bundle listName:(NSString*)sName images:(NSDictionary*)dicImages
{
    //リソースにあるplsitファイルパスの作成
    NSString* sPath = [bundle pathForResource:sName ofType:@"plist"];
    //ファイル読み込み
    NSArray* aList = [[NSArray alloc] initWithContentsOfFile:sPath ];

    //作成したフレーム情報を格納する入れ物を生成
    NSMutableArray* aCharFrame = [NSMutableArray array];
    
    //フレーム情報の読み込み
    for( NSDictionary* dicFrame in aList )
    {
        NSNumber* numX = [dicFrame objectForKey:@"x"];          //移動距離取得
        NSString* sName = [dicFrame objectForKey:@"frame"];     //使用フレーム画像名取得
        
        NSCharFrame* frame = [[NSCharFrame alloc] init];        //フレーム情報の入れ物生成
        
        frame->ptMove.x = [numX floatValue];                    //移動距離
        frame->ptMove.y = 0;                                    //縦移動は無いので0固定
        frame->img = [dicImages objectForKey: sName];           //名前から使用画像(NSImage)を取得し設定
        
        [aCharFrame addObject:frame];                           //１フレーム分の情報を格納
    }
        
    return [aCharFrame copy];   //NSMutableArrayからNSArray型の複製を生成し返す
}

/**
 *  メイニャンキャラの生成
 *  @param  persons [I/-]   生成する人数
 *  @return 人数分生成されたNSCharactarオブジェクトが格納されたNSArrayオブジェクト
 */
-(NSArray*)CreateMeinyans:(NSInteger)persons
{
    NSMutableArray* meinyans = [NSMutableArray array];
    
    for(NSInteger iCnt=0; iCnt<persons; iCnt++ )
    {
        //キャラオブジェクト生成
        NSCharactar* meinyan = [[NSCharactar alloc] init];
        //使用データ設定
        if(![meinyan initData:self.frame L2RPattern:_aImgMeinyanLeft R2LPattern:_aImgMeinyanRight])    break;
        //初期動作設定
        [meinyan setWaitPattern:(iCnt*5)];
        //格納
        [meinyans addObject:meinyan];
    }
    
    return [meinyans copy]; //NSMutableArrayからNSArray型の複製を生成し返す
}

/**
 *  スクリーンセーバーの設定値読み込み
 *  @return 読み込み結果
 *  @retval TRUE    読み込み完了
 *  @retval FALSE   読み込み失敗
 */
-(BOOL)LoadSettingValue
{
    //初期設定を読み
    ScreenSaverDefaults *ssd = [ ScreenSaverDefaults defaultsForModuleWithName : @"MeinyanSaver" ];
    if ( !ssd ) return FALSE;
    
    //設定値の読み出し
    _persons    = [ ssd integerForKey:@"persons" ];     //表示人数
    _interval   = [ ssd integerForKey:@"interval" ];    //表示速度
    _alpha      = [ ssd integerForKey:@"alpha" ];       //残像濃度
    
    //変な値だったら(初回とか)強制的に値を設定
    if( 0 >= _persons ) _persons = 50;
    if( 0 >= _interval ) _interval = 3;
    if( 0 > _alpha ) _alpha = 0;
    
//    NSLog(@"**LoadSettingValue**");
//    NSLog(@"Persons=%d",(int)_persons);
//    NSLog(@"Interval=%d",(int)_interval);
//    NSLog(@"Alpha=%d",(int)_alpha);
    
    return TRUE;
}

/**
 *  スクリーンセーバ設定オプションウインドのクローズ時処理
 */
- (IBAction)closeOptionWindow:(id)sender
{
    _persons = _txtPersons.integerValue;
    _interval = _txtInterval.integerValue;
    _alpha = _txtAlpha.integerValue;
    
//    NSLog(@"**closeOptionWindow**");
//    NSLog(@"Persons=%d",(int)_persons);
//    NSLog(@"Interval=%d",(int)_interval);
//    NSLog(@"Alpha=%d",(int)_alpha);
    
    //設定値を保存する
    ScreenSaverDefaults *ssd = [ ScreenSaverDefaults defaultsForModuleWithName : @"MeinyanSaver" ]; //設定を保存するオブジェクト取得
    [ ssd setInteger:_persons forKey:@"persons" ];      //表示人数設定
    [ ssd setInteger:_interval forKey:@"interval" ];    //表示速度設定
    [ ssd setInteger:_alpha forKey:@"alpha"];           //残像濃度設定
    [ ssd synchronize ];                                //保存
    
    //スクリーンセーバー設定ウインドを閉じる
    [NSApp endSheet:configSheet];
}

/**
 *  表示人数入力フィールド変更時アクション
 *  @note   InterfaceBuilder側で編集不可設定になっているので使われていません
 */
-(IBAction)inputPersons:(id)sender
{
    _sldPerson.integerValue = _txtPersons.integerValue;
}

/**
 *  人数スライダー変化時アクション
 */
-(IBAction)chengePersons:(id)sender
{
    //表示人数入力テキストフィールドに値を反映
    _txtPersons.integerValue = _sldPerson.integerValue;
}

/**
 *  表示速度入力フィールド変更時アクション
 *  @note   InterfaceBuilder側で編集不可設定になっているので使われていません
 */
-(IBAction)inputInterval:(id)sender
{
    _sldInterval.integerValue = _txtInterval.integerValue;
}

/**
 *  表示速度スライダー変化時アクション
 */
-(IBAction)chengeInterval:(id)sender
{
    //表示人数入力テキストフィールドに値を反映
    _txtInterval.stringValue = _sldInterval.stringValue;
}

/**
 *  残像濃度入力フィールド変更時アクション
 *  @note   InterfaceBuilder側で編集不可設定になっているので使われていません
 */
-(IBAction)inputAlpha:(id)sender
{
    _sldAlpha.integerValue = _txtAlpha.integerValue;
}

/**
 *  残像濃度スライダー変化時アクション
 */
-(IBAction)chengeAlpha:(id)sender
{
    //残像濃度入力テキストフィールドに値を反映
    _txtAlpha.stringValue = _sldAlpha.stringValue;
}
@end
