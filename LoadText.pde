//テキストファイルから文章をロード＋長い文を分割--------------------------
void loadText() {
  String[] oriLines = loadStrings("text-0.txt");
  ArrayList<String> strList = new ArrayList<String>();
  PFont font = createFont(fontName, textWidth);
  textFont(font);
  ArrayList<Integer> splitList = new ArrayList<Integer>();
  float lineWidth = rrWidth-padding*2;

  for (int i = 0; i < oriLines.length; i++) {
    float tw = 0;
    splitList.clear();
    for (int j = 0; j < oriLines[i].length(); j++) {
      char c1 = oriLines[i].charAt(j); //i番目の文字を取得
      float charWidth = textWidth(c1); //文字の幅を取得
      if (j == oriLines[i].length()-1) {
        if (c1 == '、' || c1 == '。') {
          charWidth = 0;
        }
      }
      tw += charWidth;
      if (tw > lineWidth) {
        splitList.add(j);
        tw = 0;
      }
    }
    int splitNum = splitList.size();
    if (splitNum==0) {
      strList.add(oriLines[i]);
    }
    String str;
    for (int k = 0; k < splitNum; k++) {
      int spl = splitList.get(k);
      if (splitNum == 1) {
        str = oriLines[i].substring(0, spl);
        strList.add(str);
        str = oriLines[i].substring(spl);
        strList.add(str);
      } else if (splitNum == 2) {
        if (k == 0) {
          str = oriLines[i].substring(0, spl);
          strList.add(str);
        } else {
          str = oriLines[i].substring(splitList.get(k-1), spl);
          strList.add(str);
          str = oriLines[i].substring(spl);
          strList.add(str);
        }
      } else {
        if (k == 0) {
          str = oriLines[i].substring(0, spl);
          strList.add(str);
        } else if (k == splitNum-1) {
          str = oriLines[i].substring(splitList.get(k-1), spl);
          strList.add(str);
          str = oriLines[i].substring(spl);
          strList.add(str);
        } else {
          str = oriLines[i].substring(splitList.get(k-1), spl);
          strList.add(str);
        }
      }
    }
  }
  lines = strList.toArray(new String[strList.size()]);
}
