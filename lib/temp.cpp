/*
g++ XXX.cpp
./a.out
*/
#include <bits/stdc++.h>
using namespace std;
vector<int>coinValue = {1, 5, 10, 50, 100, 500};

void dfs(int &value, int coinIndex, vector<int>coins, int sum, int &minCnt, vector<int>&out, vector<int>&otr, int &c1000){
  if (coinIndex < 0){
    int dif = sum + c1000 * 1000 - value;
    if (dif < 0) return;
    int cnt = 0;
    vector<int>otrbf(6);
    for (int i=0;i<6;i++){
      int co = coinValue.at(5 - i);
      otrbf.at(5 - i) += dif / co;
      cnt += dif / co;
      dif -= co * (dif / co);
    }
    if (cnt <= minCnt){
      minCnt = cnt;
      out = coins;
      otr = otrbf;
    }
    return;
  }
  vector<int>coinsBf = coins;
  for (int i=0;i<=coins.at(coinIndex);i++){
    coinsBf.at(coinIndex) = i;
    dfs(value, coinIndex - 1, coinsBf, sum + coinValue.at(coinIndex) * i, minCnt, out, otr, c1000);
  }
}

int main() {
  vector<int>coins = {4, 1, 4, 1, 4, 1};
  while(true){
    int value; cin >> value;
    if (value == 0){
      for (int i=0;i<6;i++) cin >> coins.at(i);
      for (int i=0;i<6;i++) cout << coins.at(i) << ":";
      cout << endl;
      continue;
    }
    int c1000 = value / 1000;
    int cnt = 1000;
    vector<int>out(6);
    vector<int>otr(6);
    if (coins.at(0) + coins.at(1) * 5 + coins.at(2) * 10 + coins.at(3) * 50 + coins.at(4) * 100 + coins.at(5) * 500 + c1000 * 1000 < value) c1000++;
    dfs(value, 5, coins, 0, cnt, out, otr, c1000);
    int sum = 0;
    for (int i=0;i<6;i++){
      sum += coinValue.at(i) * out.at(i);
    }
    cout << sum + c1000 * 1000 << endl;
    for (int i=0;i<6;i++) coins.at(i) -= out.at(i);
    for (int i=0;i<6;i++) coins.at(i) += otr.at(i);
    for (int i=0;i<6;i++) cout << coins.at(i) << ":";
    cout << endl;
  }
  return 0;
}