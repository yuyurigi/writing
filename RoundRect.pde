class RoundRect {
  float x, y, rwidth, rheight, eY, startY, goalY;

  RoundRect(float _x, float _y, float _rwidth, float _rheight) {
    x = _x;
    y = _y;
    rwidth = _rwidth;
    rheight = _rheight;
  }

  void display() {
    fill(255);
    noStroke();
    rect(x, y, rwidth, rheight, 30);
  }

  void setEasing(float _startY, float _goalY) {
    eY = 0;
    startY = _startY;
    goalY = _goalY;
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
