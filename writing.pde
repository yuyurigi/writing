import geomerative.*;
import java.util.Calendar;
import java.util.Iterator;

boolean bGuide = false; //ガイドの表示

RShape[] grp;
RShape[] emo;
int textWidth = 60; //一文字の大きさ
int currentLine = 0;
int time = 0; //文字に使う値
int aniTime = 0; //キャラのアニメーション用タイム
int interval = 1100; //１文書く間隔（数値が大きいほど遅くなる）
int textSpace = 65; //行間
int bodyFrame = 0; //現在のキャラのフレーム
int eyeFrame = 0; //現在の目のフレーム
int currentFrame = 0;
int wink, newLineNum, currentNewLine, nextMode;
int mode = 0; //0:テキストを書く 1:改行 
//2:上目（そのあと消しゴム） 3:ペンと消しゴムを入れ替える 4:文字を消す 5:消しゴムとペンを入れ替える 
//6:改行（マイナス）
//7:上目 
//8:上目（そのあとページめくり） 9:ページめくる　
//(怒り）10:上目（そのあと消しゴム） 11:ペンと消しゴムを入れ替える 12:文字を消す 13:消しゴムとペンを入れ替える 
//(怒り）14:上目 
//(怒り）15:上目（そのあとページめくり） 16:ページめくる
int prevMode; //１フレーム前のmodeの値
int eraserCount = 0; //消しゴムかけてる時間
int mousePressedNum = 0; //何回キャラを押したかカウントする
int[] intervals;
float[] lineWidths;
float div, textX, textY, imageX, imageY, rrX, rrY, rrHeight;
float padding = 50; //四角形と文字の間のパディング
float rrWidth = 718; //四角形の幅
String[] lines;
String[] emojis;
String imageName = "images[0]";
String fontName = "APJapanesefont.ttf";
PFont textFont;
PImage[] images = new PImage[26];
PImage[] eyes = new PImage[14];
PImage[] borderImage = new PImage[3];
PImage mouseCursor, handCursor;
boolean bEye = false;
boolean prevbEye; //１フレーム前のbEyeの値
//boolean bEraser = false; //消しゴムモードを起動させるまではEraserの表示をしない
boolean bMouseOver = false; //キャラにマウスオーバーしてるかどうか
boolean bMousePressed = false;
boolean bAngry = false; //キャラが怒った顔になるためのbool値
boolean bEndAddLine = false;
ArrayList<Text> texts = new ArrayList<Text>();
ArrayList<RoundRect> rrect = new ArrayList<RoundRect>();
ArrayList<Integer> textNum = new ArrayList<Integer>(); //四角形の中にテキストが何行おさまってるか
FloatList textCurrentY = new FloatList();
ArrayList<Eraser> erasers = new ArrayList<Eraser>();

int mousePressedMode;

void setup() {
  size(1080, 608);
  frameRate(60);
  smooth();

  //文章をロード
  RG.init(this);
  loadText();
  grp = new RShape[lines.length];

  //フォントをロード
  for (int i = 0; i < lines.length; i++) {
    grp[i] = RG.getText(lines[i], fontName, textWidth, LEFT);
  }

  //ガイド用のフォント
  textFont = createFont("Kodchasan-Medium.ttf", 28);
  textFont(textFont);

  //１文書く間隔（どの文の長さでも描画スピードを一定にする）
  intervals = new int[lines.length];
  lineWidths = new float[lines.length]; //各文の幅を格納
  float lw = rrWidth-padding*2;
  div = interval/lw;
  for (int i = 0; i < intervals.length; i++) {
    //文の幅を取得
    float lineWidth = grp[i].getBottomRight().x - grp[i].getBottomLeft().x;
    lineWidths[i] = lineWidth;
    intervals[i] = int(div*lineWidth);
  }

  //画像をロード
  //キャラ
  for (int i = 0; i < images.length; i++) {
    String imageName = "ani-" + nf(i, 1) + ".png";
    images[i] = loadImage(imageName);
  }
  //目
  for (int i = 0; i < eyes.length; i++) {
    String imageName = "eye-" + nf(i, 1) + ".png";
    eyes[i] = loadImage(imageName);
  }
  //キャラにマウスオン時の境界線用画像
  for (int i = 0; i < borderImage.length; i++) {
    String imageName = "border-" + nf(i, 1) + ".png";
    borderImage[i] = loadImage(imageName);
  }

  //画像の位置
  imageX = width-images[0].width-20;
  imageY = height-images[0].height-10;
  //テキストのy位置
  textX = 80;
  textY = height-90;
  //最初のテキストを追加
  texts.add(new Text(0));

  //四角形を追加
  rrX = textX-padding;
  rrY = textY-textSpace-padding;
  rrHeight = textSpace*(lines.length)+padding*2;
  rrect.add(new RoundRect(rrX, rrY, rrWidth, rrHeight));
}

void draw() {
  //背景------------------------------------------------------------
  background(#4f9495); //背景

  //キャラにマウスオン時----------------------------------------------
  mouseOver();

  //キャラ----------------------------------------------------------
  if (bMouseOver) image(borderImage[bodyFrame], imageX, imageY);
  image(images[bodyFrame], imageX, imageY);
  if (prevMode != mode) aniTime = 0;

  //画像が切り替わるスピードを調整
  int frame;
  if (mode==4 && mode==12) {
    frame = aniTime % 5; //消しゴム（早くする）
  } else {
    frame = aniTime % 10;
  }

  if (mode == 0) { //テキストの描画をしてるときだけ動く
    if (frame == 1) {
      bodyFrame = int(random(3));
    }
  }

  if (mode == 3) { //ペンから消しゴムに持ち替え
    if (bodyFrame < 13 && frame == 1) {
      bodyFrame+=1;
    }
    if (bodyFrame == 13) {
      mode = 4; //ペンから消しゴムに持ち替える動作が終わったらモード変更
      bodyFrame = 14; //キャラの画像を変更
      eyeFrame = 0; //目の画像を変更
    }
  }

  if (mode == 4) { //消しゴム
    if (frame == 1) {
      bodyFrame = int(random(13, 16));
    }

    if (eraserCount > 4*60) { //少しの間消しゴムをかける(60はframeRate)
      changeMode5();
    }
  }

  if (mode == 5) { //消しゴムとペンを入れ替える
    if (bodyFrame > 3 && frame == 1) {
      bodyFrame-=1;
    }
    if (bodyFrame == 3) {
      mode = 0; //最初に戻る
      bodyFrame = 2;
      eyeFrame = 0;
    }
  }

  if ((mode==1 && currentLine==0) || mode == 9 || mode == 16) { //ページめくる
    if (bodyFrame < 26 && frame == 1) {
      if (bodyFrame < 16) {
        bodyFrame=16;
      } else {
        bodyFrame+=1;
      }
    }


    if (bodyFrame > 25 && bEndAddLine == true) {
      mode = 0; //モード変更
      bodyFrame = 0;
      eyeFrame = 0;
      bEndAddLine = false;
    }
  }

  //(怒り）消しゴム
  if (mode == 11) { //ペンから消しゴムに持ち替え
    if (bodyFrame < 13 && frame == 1) {
      bodyFrame+=1;
    }
    if (bodyFrame == 13) {
      mode = 12; //ペンから消しゴムに持ち替える動作が終わったらモード変更
      bodyFrame = 14; //キャラの画像を変更
      eyeFrame = 8; //目の画像を変更
    }
  }

  if (mode == 12) { //消しゴム
    if (frame == 1) {
      bodyFrame = int(random(13, 16));
    }

    if (eraserCount > 4*60) { //少しの間消しゴムをかける(60はframeRate)
      changeMode13();
    }
  }

  if (mode == 13) { //消しゴムとペンを入れ替える
    if (bodyFrame > 3 && frame == 1) {
      bodyFrame-=1;
    }
    if (bodyFrame == 3) {
      mode = 0; //最初に戻る
      bodyFrame = 2;
      eyeFrame = 0;
    }
  }

  //目--------------------------------------------------------------
  image(eyes[eyeFrame], imageX, imageY);
  //println(eyeFrame);
  if (mode == 0 || mode == 1) { //テキストを書く、改行
    if (!bMousePressed) wink(0, 2); //0~2番目の目の画像を使用してウィンク
  }
  //消しゴム
  if (mode == 2) { //上目
    eyeFrame = 3; //3番目の目の画像を使用

    if (frameCount > currentFrame+1*60) { //少しの間、上目づかい(60はframeRate)
      //上目づかいのあと
      mode=3; //モード変更
      eyeFrame = 4; //目の画像を変更
      bodyFrame = 2; //キャラの画像を変更
    }
  } else if (mode == 3) { //ペンから消しゴムに持ち替え
    wink(4, 6); //4~6番目の目の画像を使用してウィンク
  } else if (mode == 4) { //消しゴム
    wink(0, 2); //0~2番目の目の画像を使用してウィンク
  } else if (mode == 5) { //消しゴムからペンに持ち替え
    wink(4, 6);
  }

  //上目
  if (mode == 7) {
    eyeFrame = 3; //3番目の目の画像を使用

    if (frameCount > currentFrame+1*60) { //少しの間、上目づかい(60はframeRate)
      //上目づかいのあと
      mode=0; //モード変更
      eyeFrame = 0; //目の画像を変更
    }
  }

  //ページめくり
  if (mode == 8) { //上目
    eyeFrame = 3; //3番目の目の画像を使用

    if (frameCount > currentFrame+1*60) { //少しの間、上目づかい(60はframeRate)
      //上目づかいのあと
      mode=9; //モード変更
      eyeFrame = 0; //目の画像を変更
      bodyFrame = 16; //キャラの画像を変更
    }
  } else if (mode == 9) { //ページめくり
    wink(0, 2);
  }

  //消しゴム(怒り）
  if (mode == 10) { //上目
    eyeFrame = 7; //7番目の目の画像を使用

    if (frameCount > currentFrame+1*60) { //少しの間、上目づかい(60はframeRate)
      //上目づかいのあと
      mode=11; //モード変更
      eyeFrame = 11; //目の画像を変更
      bodyFrame = 2; //キャラの画像を変更
    }
  } else if (mode == 11) { //ペンから消しゴムに持ち替え
    wink(11, 13); //11~13番目の目の画像を使用してウィンク
  } else if (mode == 12) { //消しゴム
    wink(8, 10); //8~10番目の目の画像を使用してウィンク
  } else if (mode == 13) { //消しゴムからペンに持ち替え
    wink(11, 13);
  }

  //上目（怒り）
  if (mode == 14) {
    eyeFrame = 7; //7番目の目の画像を使用

    if (frameCount > currentFrame+1*60) { //少しの間、上目づかい(60はframeRate)
      //上目づかいのあと
      mode=0; //モード変更
      eyeFrame = 0; //目の画像を変更
    }
  }

  //ページめくり（怒り）
  if (mode == 15) {
    eyeFrame = 7; //7番目の目の画像を使用

    if (frameCount > currentFrame+1*60) { //少しの間、上目づかい(60はframeRate)
      //上目づかいのあと
      mode=16; //モード変更
      eyeFrame = 11; //目の画像を変更
      bodyFrame = 16; //キャラの画像を変更
    }
  } else if (mode == 16) {
    wink(11, 13);
  }

  //四角形の描画----------------------------------------------------
  for (int i = 0; i < rrect.size(); i++) {
    rrect.get(i).display();
  }

  //テキスト-------------------------------------------------------
  if (mode == 0) {
    if (grp[currentLine].countChildren() == 0) mode = 1; //文字が空白のときは改行
  } else if (mode == 4 || mode == 12) {
    if (grp[currentLine].countChildren() == 0) mode = 6; //（消しゴム時）文字が空白のときは-改行
  }

  if ((mode==0 && prevMode==5) || (mode==0 && prevMode==13)) {
    //消しゴムかけた後のテキスト
    float currentX = erasers.get(erasers.size()-1).location.x-textX-textWidth*1.3;
    if (currentX < 0) currentX = 0;
    float spPos = currentX / lineWidths[currentLine];
    time = int(map(spPos, 0, 1, 0, intervals[currentLine]-1));
  }

  //消しゴム-------------------------------------------------------
  if (mode==4 && prevMode!=4) {
    if (erasers.size()>0) {
      if (erasers.get(erasers.size()-1).y == textY-textSpace) {
        erasers.remove(erasers.size()-1);
      }
    }
    erasers.add(new Eraser(currentLine));
    if (bGuide) erasers.get(erasers.size()-1).setNum(erasers.size()-1);
  } else if (mode==4 && prevMode==4) {
    float eraserX = erasers.get(erasers.size()-1).location.x;
    if (currentLine==0 && eraserX<textX) { //消しゴムが最初の行の頭まで来たら
      changeMode5();
    } else if (currentLine!=0 && eraserX<textX) { //消しゴムが行の頭まで来たらマイナス改行
      mode = 6;
    }
  }

  //怒り顔のとき
  if (mode==12 && prevMode==11) {
    if (erasers.size()>0) {
      if (erasers.get(erasers.size()-1).y == textY-textSpace) {
        erasers.remove(erasers.size()-1);
      }
    }
    erasers.add(new Eraser(currentLine));
    if (bGuide) erasers.get(erasers.size()-1).setNum(erasers.size()-1);
  } else if (mode==12 && prevMode==12) {
    float eraserX = erasers.get(erasers.size()-1).location.x;
    if (currentLine==0 && eraserX<textX) { //消しゴムが最初の行の頭まで来たら
      changeMode13(); //消しゴムを止める
    } else if (currentLine!=0 && eraserX<textX) {
      mode = 6;
    }
  }

  //消しゴムとテキストの表示-----------------------------------------
  for (int i = 0; i < erasers.size()-1; i++) {
    erasers.get(i).display();
  }
  if (mode!=4 && mode!=5 && mode!=6 && mode!=12 && mode!=13) {
    if (erasers.size()>0) erasers.get(erasers.size()-1).display();
  }

  //テキスト
  pushMatrix();
  translate(textX, textY);
  for (int i = 0; i < texts.size(); i++) {
    texts.get(i).display(); //テキスト表示
  }
  popMatrix();

  if (mode==4 || mode==5 || mode==6 || mode==12 || mode == 13) { //消しゴム時、[テキスト　消しゴム]の順
    if (erasers.size()>0) erasers.get(erasers.size()-1).display(); //現在の消しゴムを表示
  }

  //time---------------------------------------------------------
  if (mode == 0) { //文章を書いてるとき
    time++;
  } else if (mode==4 || mode == 12) { //消しゴム
    eraserCount++;
  }

  if (mode==0 && time%intervals[currentLine]==0) { //１文書き終わったとき
    time = 0;
    if (currentLine == lines.length-1) {
      mode = 9; //ページめくる
    } else {
      nextMode = 0;
      mode = 1; //改行
    }
  }

  if (mode==1) {
    addLine(); //改行
  }

  if (mode==6) {
    minusLine(); //改行（マイナス）
  }

  if (mode==9 || mode==16) { //ページめくり
    addLine2(); //改行
    time = 0;
  }

  prevMode = mode;
  prevbEye = bEye;
  aniTime++;

  //ガイド----------------------------------------------------------

  if (bGuide) {
    fill(0);
    text("mode:"+mode, width-400, 300); //現在のモード番号を画面に表示
    text("prevMode:"+prevMode, width-450, 340);

    text("currentLine:"+currentLine, 30, 60);
    text("mousePressedNum:" + mousePressedNum, 30, 100);
    text("rrect.size:" + rrect.size(), 30, 140);
    text("texts.size:" + texts.size(), 30, 170);
    text("bodyFrame:" + bodyFrame, 30, 200);
    text("textNum:" + textNum, 30, 230);
    text("erasers.size:" + erasers.size(), 30, 260);
    text("nextMode:" + nextMode, 30, 290);
    text("bMousePressed:" + bMousePressed, 30, 320);
    text("mousePressedMode:" + mousePressedMode, 30, 350);

    stroke(#FAF481);
    line(0, height-608, width, height-608);
  }
}

//キャラにマウスオン時------------------------------------------------
void mouseOver() {
  if (mode == 0 || mode == 1) {
    if (imageX < mouseX && mouseX < (imageX+images[0].width) &&
      imageY < mouseY && mouseY < (imageY+images[0].height)) {
      bMouseOver = true;
      cursor(HAND);
    } else {
      bMouseOver = false;
      cursor(ARROW);
    }
  } else {
    bMouseOver = false;
    cursor(ARROW);
  }
}

//目のまばたき-------------------------------------------------------
void wink(int first, int end) { 
  int space = int(random(80, 150)); //まばたきするタイミング（ランダム）
  int frame2 = frameCount % space;
  if (frame2 == space-1) {
    bEye = true; //まばたきを有効にする
  }
  if (bEye) {
    if (bEye != prevbEye) {
      wink = 0; //まばたきに使う数値
    }
    //まばたきのスピード
    if (wink%4 == 3) {
      eyeFrame += 1;
    }
    if (eyeFrame == end+1) { //まばたき終了
      eyeFrame = first;
      bEye = false;
    }
  }
  wink++;
}

//モード５に変更------------------------------------------------------
void changeMode5() {
  //消しゴムを止める
  erasers.get(erasers.size()-1).setVelocity(0, 0);

  mode = 5; //モード変更
  bodyFrame = 13;
  eyeFrame = 4;
  eraserCount = 0;
}

//モード１３に変更------------------------------------------------------
void changeMode13() {
  //消しゴムを止める
  erasers.get(erasers.size()-1).setVelocity(0, 0);

  mode = 13; //モード変更
  bodyFrame = 13;
  eyeFrame = 11;
  eraserCount = 0;
}
//マウス押した時のイベント---------------------------------------------
void mousePressed() {
  if (bGuide) mousePressedMode = mode;
  if (mode == 0) {
    currentFrame = frameCount;
    mousePressedNum += 1;
    int eventNum;
    if (mousePressedNum < 5) {
      eventNum = mousePressedNum%3;
    } else {
      bAngry = true;
      eventNum = (int)random(3);
    }

    if (eventNum == 1 && !bAngry) {
      mode = 2;
    } else if (eventNum == 2 && !bAngry) {
      mode = 7;
    } else if (eventNum == 0 && !bAngry) {
      mode = 8;
    } else if (eventNum == 1 && bAngry) {
      mode = 10;
    } else if (eventNum == 2 && bAngry) {
      mode = 14;
    } else if (eventNum == 0 && bAngry) {
      mode = 15;
    }
  } 

  if (mode == 1) {
    bMousePressed = true;
    currentFrame = frameCount;
    mousePressedNum += 1;
    int eventNum;
    if (mousePressedNum < 5) {
      eventNum = mousePressedNum%3;
    } else {
      bAngry = true;
      eventNum = (int)random(3);
    }

    if (!bAngry) {
      eyeFrame = 3; //上目
    } else {
      eyeFrame = 7; //上目（怒）
    }

    if (eventNum == 1 && !bAngry) {
      nextMode = 2;
    } else if (eventNum == 2 && !bAngry) {
      nextMode = 7;
    } else if (eventNum == 0 && !bAngry) {
      nextMode = 8;
    } else if (eventNum == 1 && bAngry) {
      nextMode = 10;
    } else if (eventNum == 2 && bAngry) {
      nextMode = 14;
    } else if (eventNum == 0 && bAngry) {
      nextMode = 15;
    }
  }
}


//キーを押した時のイベント---------------------------------------------
void keyPressed() {
  if (key == 's' || key == 'S')saveFrame(timestamp()+"_####.png");
}

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
