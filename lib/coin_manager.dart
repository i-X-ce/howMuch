import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const coinValues = [1, 5, 10, 50, 100, 500, 1000];

class CoinState extends ChangeNotifier {
  var coinCnt = [4, 1, 4, 1, 4, 1];
  var costCoins = [0, 0, 0, 0, 0, 0, 0];

  addCoin(index) {
    coinCnt[index] = min((coinCnt[index] as int) + 1, 99);
    notifyListeners();
  }

  decCoin(index) {
    coinCnt[index] = max((coinCnt[index] as int) - 1, 0);
    notifyListeners();
  }

  coinsCnt() {
    int cnt = 0;
    for (var i = 0; i < 6; i++) {
      cnt += coinCnt[i] as int;
    }
    return cnt;
  }

  outCostCoins(value) {
    CalcCoin calcCoin = CalcCoin(value: value, coins: coinCnt);
    calcCoin.calc();
    coinCnt = calcCoin.coins;
    costCoins = calcCoin.out;
    notifyListeners();
  }

  initCoinCnt() {
    coinCnt = [4, 1, 4, 1, 4, 1];
    costCoins = [0, 0, 0, 0, 0, 0, 0];
    notifyListeners();
  }
}

class CalcCoin {
  CalcCoin({
    required this.value,
    required this.coins,
  });

  final int value;
  final coins;
  var otr = [0, 0, 0, 0, 0, 0];
  var out = [0, 0, 0, 0, 0, 0];
  var minCnt = 10000;
  int c1000 = 0;

  calc() {
    c1000 = (value / 1000).toInt();
    int sum = 0;
    for (var i = 0; i < 6; i++) {
      sum += coins[i] * coinValues[i] as int;
    }
    if (sum + c1000 * 1000 < value) c1000++;
    dfs(5, coins, 0);
    for (var i = 0; i < 6; i++) {
      sum += coins[i] * coinValues[i] as int;
    }
    sum += c1000 * 1000;

    for (var i = 0; i < 6; i++) {
      coins[i] -= out[i];
      coins[i] += otr[i];
    }
  }

  dfs(int coinIndex, coss, sum) {
    if (coinIndex < 0) {
      int dif = sum + c1000 * 1000 - value;
      if (dif < 0) return;
      int cnt = 0;
      var otrbf = [0, 0, 0, 0, 0, 0];
      for (var i = 0; i < 6; i++) {
        int co = coinValues[5 - i];
        otrbf[5 - i] += (dif / co).toInt();
        cnt += (dif / co).toInt();
        dif -= co * (dif / co).toInt();
      }
      if (cnt <= minCnt) {
        minCnt = cnt;
        out = List<int>.from(coss);
        otr = List<int>.from(otrbf);
      }
      return;
    }
    var coinBf = List<int>.from(coss);
    for (var i = 0; i <= coss[coinIndex]; i++) {
      coinBf[coinIndex] = i;
      dfs(coinIndex - 1, coinBf, sum + coinValues[coinIndex] * i);
    }
  }
}

class CoinManipulatorContent extends StatefulWidget {
  @override
  State<CoinManipulatorContent> createState() => _CoinManipulatorContentState();
}

class _CoinManipulatorContentState extends State<CoinManipulatorContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 4; i++)
              Flexible(
                child: CoinUI(
                  coinIndex: i,
                ),
              ),
          ],
        ),
        Row(
          children: [
            for (var i = 0; i < 2; i++)
              Flexible(
                  child: CoinUI(
                coinIndex: i + 4,
              )),
          ],
        ),
        IconButton(
          onPressed: ()=>{ Provider.of<CoinState>(context, listen: false).initCoinCnt()}, 
          icon: Icon(Icons.restart_alt)),
      ],
    );
  }
}

class CoinUI extends StatelessWidget {
  const CoinUI({
    super.key,
    required this.coinIndex,
  });

  final int coinIndex;

  @override
  Widget build(BuildContext context) {
    var cState = context.watch<CoinState>();

    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(coinValues[coinIndex].toString()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                child: IconButton(
                    onPressed: () => cState.decCoin(coinIndex),
                    icon: Icon(Icons.remove))),
            Text(cState.coinCnt[coinIndex].toString()),
            Flexible(
                child: IconButton(
                    onPressed: () => cState.addCoin(coinIndex),
                    icon: Icon(Icons.add))),
          ],
        )
      ],
    );
  }
}

class CoinDisplayContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cState = context.watch<CoinState>();

    return Card(
      color: Theme.of(context).colorScheme.inversePrimary,
      child: Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < 4; i++)
                CostCoinUI(value: coinValues[i], cnt: cState.costCoins[i]),
            ],
          ),
          Row(
            children: [
              for (int i = 4; i < 6; i++)
                CostCoinUI(value: coinValues[i], cnt: cState.costCoins[i]),
            ],
          ),
        ],
      ),
    );
  }
}

class CostCoinUI extends StatelessWidget {
  CostCoinUI({
    super.key,
    required this.value,
    required this.cnt,
  });

  final int value;
  final int cnt;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: cnt == 0
              ? Colors.transparent
              : Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            value.toString(),
            style: TextStyle(
              color: cnt == 0
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        Text(
          cnt.toString(),
          style: TextStyle(
            color: cnt == 0
                ? Colors.transparent
                : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

class InputContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cState = context.watch<CoinState>();
    var _controller = TextEditingController();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            maxLength: 4,
            maxLines: 1,
            controller: _controller,
            decoration: InputDecoration(
                icon: Icon(Icons.currency_yen),
                hintText: "問題の金額",
                labelText: "金額",
                suffixIcon: IconButton(
                    onPressed: () => {},
                    icon: Icon(Icons.clear))),
            onSubmitted: (value) => {cState.outCostCoins(int.parse(value))},
          ),
        ),
        Text(style: TextStyle(fontSize: 26), '${cState.coinsCnt()}枚')
      ],
    );
  }
}
