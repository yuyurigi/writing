class Text {
  float x, y; 
  int current;
  boolean bDraw, bLine, bSplit;
  float eY, startY, goalY;
  float eX, startX, goalX, lineX;
  float currentX;
  float splitPos;

  Text(int _current) {
    x = 0;
    y = 0;
    current = _current;
    bDraw = true;
    bLine = false;
  }

  void setBool(boolean _bDraw) {
    bDraw = _bDraw;
  }

  void setBoolLine(boolean _bLine) {
    bLine = _bLine;
  }
  
  void setBoolSplit(boolean _bSplit) {
    bSplit = _bSplit;
  }

  void setEasing(float _startY, float _goalY) {
    eY = 0;
    startY = _startY;
    goalY = _goalY;
  }

  void setLineEasing() {
    eX = 0;
    startX = x;
    goalX = grp[current].getBottomRight().x + startX;
  }

  void display() {
    fill(#040304);
    noStroke();
    pushMatrix();
    translate(x, y);
    if (bDraw) {
      fill(#040304);
      //現在のライン
      splitPos = map(time%intervals[current], 0, intervals[current]-1, 0, 1);
      RShape[] splitShapes = grp[current].split(splitPos);
      RG.shape(splitShapes[0]);
      currentX = splitPos*lineWidths[current]+textWidth*1.2; //現在のX値（文字を書いてるところ）(消しゴムに使う）(+textWidth*1.2で少し先になってる）
      if (bGuide) { //今どこを描いてるかのガイド
        fill(255, 0, 0);
        ellipse(currentX, 0, 10, 10);
      }
    } else {
      //現在のラインより上のライン（文字を表示するだけ）
      RShape[] splitShapes;
      splitShapes = grp[current].split(1);
      if(bSplit) splitShapes = grp[current].split(splitPos);
      RG.shape(splitShapes[0]);
    }
    popMatrix();
  }

  void move(float speed) {
    y = map(easeInOutBack(eY), 0, 1, startY, goalY);
    eY += 1 / speed; //イージングのスピード（数値が小さいほど早い）
    if (eY > 1) {
      eY = 1;
      y = goalY;
    }
  }
}
