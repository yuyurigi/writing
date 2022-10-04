//改行(1行）--------------------------------------------------------------
void addLine() {
  if (mode != prevMode) {
    texts.get(texts.size()-1).setBool(false); //今書いた文は描画中の文でなくなる
    if (currentLine == lines.length-1) {
      textNum.add(currentLine+1); //文を何行書いてるか格納

      //新しい四角形を追加
      rrect.add(new RoundRect(rrX, rrY+textSpace*3, rrWidth, rrHeight));
    }
    currentLine+=1;
    currentLine = currentLine%lines.length;
    currentNewLine = 0;
    newLineNum = 1;

    for (int i = 0; i < texts.size(); i++) {
      float currentY = texts.get(i).y;
      float newY;
      if (currentLine == 0) {
        newY = currentY-textSpace*3;
      } else {
        newY = currentY-textSpace;
      }
      //イージングで使う値
      texts.get(i).setEasing(currentY, newY);
    }
    //四角形
    for (int i = 0; i < rrect.size(); i++) {
      float currentY = rrect.get(i).y;
      float newY;
      if (currentLine == 0) {
        newY = currentY-textSpace*3;
      } else {
        newY = currentY-textSpace;
      }
      rrect.get(i).setEasing(currentY, newY);
    }
    //消しゴム
    Iterator<Eraser> it = erasers.iterator(); //いらない消しゴムは消す
    while (it.hasNext()) {
      float currentY = it.next().y;
      if (currentY == textY-textSpace) {
        it.remove();
      }
    }

    for (int i = 0; i < erasers.size(); i++) { //いる消しゴムは残して改行
      float currentY = erasers.get(i).y;
      float newY;
      if (currentLine == 0) {
        newY = currentY-textSpace*3;
      } else {
        newY = currentY-textSpace;
      }
      erasers.get(i).setEasing(currentY, newY);
    }
  }

  //イージングを使って改行する
  for (int i = 0; i < texts.size(); i++) { //テキスト
    if (currentLine == 0) { //新しいシートになるとき
      texts.get(i).move(90.00);
    } else { //通常の改行
      texts.get(i).move(50.00);
    }
  }
  for (int i = 0; i < rrect.size(); i++) { //四角形
    if (currentLine == 0) { //新しいシートになるとき
      rrect.get(i).move(90.00);
    } else { //通常の改行
      rrect.get(i).move(50.00);
    }
  }

  for (int i = 0; i < erasers.size(); i++) {
    if (currentLine == 0) { //新しいシートになるとき
      erasers.get(i).move(90.0); //消しゴム
    } else {
      erasers.get(i).move(50.0);
    }
  }

  //改行を終わらせる
  if (texts.get(0).eY == 1) {

    currentNewLine+=1;

    if (currentNewLine == newLineNum) {   
      //新しい行を追加
      texts.add(new Text(currentLine));

      if (currentLine!=0) {
        mode = nextMode;
      } else {
        bEndAddLine = true;
      }

      //画面外のテキストと四角形は削除
      deleteTextandRect();
      bMousePressed =false;
    }
  } //end--if (texts.get(0).getEY()==1)
} //end--addLine()

//改行2(文字を書いてる途中でページめくりしたとき）----------------------------------------
void addLine2() {
  if (mode != prevMode) {
    texts.get(texts.size()-1).setBool(false); //今書いた文は描画中の文でなくなる
    texts.get(texts.size()-1).setBoolSplit(true);
    rrect.get(rrect.size()-1).rheight = textSpace*(currentLine+1)+padding*2;
    textNum.add(currentLine+1); //文を何行書いてるか格納
    currentLine = 0;
    currentNewLine = 0;
    newLineNum = 1;

    //新しい四角形を追加
    rrect.add(new RoundRect(rrX, rrY+textSpace*3, rrWidth, rrHeight));

    for (int i = 0; i < texts.size(); i++) {
      float currentY = texts.get(i).y;
      float newY = currentY-textSpace*3;
      //イージングで使う値
      texts.get(i).setEasing(currentY, newY);
    }
    //四角形
    for (int i = 0; i < rrect.size(); i++) {
      float currentY = rrect.get(i).y;
      float newY = currentY-textSpace*3;
      rrect.get(i).setEasing(currentY, newY);
    }
    //消しゴム
    for (int i = 0; i < erasers.size(); i++) {
      float currentY = erasers.get(i).y;
      float newY = currentY-textSpace*3;
      erasers.get(i).setEasing(currentY, newY);
    }
  }


  //イージングを使って改行する
  for (int i = 0; i < texts.size(); i++) { //テキスト
    texts.get(i).move(86.00); //move()の中の数字、小さいほど早い
  }
  for (int i = 0; i < rrect.size(); i++) { //四角形
    rrect.get(i).move(86.00);
  }

  for (int i = 0; i < erasers.size(); i++) {
    erasers.get(i).move(86.0); //消しゴム
  }

  //改行を終わらせる
  if (texts.get(0).eY == 1) {

    currentNewLine+=1;

    if (currentNewLine == newLineNum) {   
      //新しい行を追加
      texts.add(new Text(currentLine));

      bEndAddLine = true;

      deleteTextandRect();
    }
  } //end--if (texts.get(0).getEY()==1)
} //end--addLine2()

//画面外のテキストと四角形と消しゴムを削除---------------------------------
void deleteTextandRect() {
  if (currentLine==0 && rrect.size()>2) {
    float rrBottomY = rrect.get(0).y + rrect.get(0).rheight;
    if (rrBottomY < 0) {
     // if (rrBottomY < (height-608)) {
      int deleteText = textNum.get(0);
      texts.subList(0, deleteText).clear(); //テキストを削除
      rrect.remove(0); //四角形を削除
      textNum.remove(0);
    }

    //消しゴムを削除
    Iterator<Eraser> it = erasers.iterator();
    while (it.hasNext()) {
      float currentY = it.next().y;
      if (currentY < 0) {
        it.remove();
      }
    }
    
  }
}

//改行（マイナス）----------------------------------------------------
void minusLine() {
  if (mode != prevMode) {

    for (int i = 0; i < texts.size(); i++) {
      float currentY = texts.get(i).y;
      float newY = currentY+textSpace;
      //イージングで使う値
      texts.get(i).setEasing(currentY, newY);
    }
    //四角形
    for (int i = 0; i < rrect.size(); i++) {
      float currentY = rrect.get(i).y;
      float newY = currentY+textSpace;
      rrect.get(i).setEasing(currentY, newY);
    }

    for (int i = 0; i < erasers.size(); i++) {
      float currentY = erasers.get(i).y;
      float newY = currentY+textSpace;
      erasers.get(i).setEasing(currentY, newY);
    }
  }

  //イージングを使って改行する
  for (int i = 0; i < texts.size(); i++) { //テキスト
    texts.get(i).move(50.0); //move(float speed) : speedの数値が小さいほど早い
  }
  for (int i = 0; i < rrect.size(); i++) { //四角形
    rrect.get(i).move(50.0);
  }
  for (int i = 0; i < erasers.size(); i++) { //消しゴム
    erasers.get(i).move(50.0);
  }

  //改行を終わらせる
  if (texts.get(0).eY==1) {
    texts.remove(texts.size()-1); //最後のテキストを削除
    currentLine-=1;
    currentLine = currentLine%lines.length;

    if (erasers.size()>0) erasers.remove(erasers.size()-1);
    erasers.add(new Eraser(currentLine));
    if (bGuide) erasers.get(erasers.size()-1).setNum(erasers.size()-1);
    if (grp[currentLine].countChildren() != 0) {
      texts.get(texts.size()-1).setBool(true); //前の行をアクティブにする
    }
    time=1;

    if (!bAngry) {
      mode = 4;
    } else {
      mode = 12;
    }
  } //end--if (texts.get(0).getEY()==1)
} //end--minusLine()
