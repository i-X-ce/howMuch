import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const coinValues = [1, 5, 10, 50, 100, 500, 1000];

class CoinState extends ChangeNotifier {
  CoinState() {
    initState();
  }

  var coinCnt;
  var costCoins;
  var costCoinSum;
  var otrSum;
  var inValue;

  initState() {
    coinCnt = [4, 1, 4, 1, 4, 1];
    costCoins = [0, 0, 0, 0, 0, 0, 0];
    costCoinSum = 0;
    otrSum = 0;
    inValue = 0;
  }

  addCoin(index) {
    coinCnt[index] = min((coinCnt[index] as int) + 1, 20);
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
    inValue = value;
    CalcCoin calcCoin = CalcCoin(value: value, coins: coinCnt);
    calcCoin.calc();
    coinCnt = calcCoin.coins;
    costCoins = calcCoin.out;
    costCoinSum = calcCoin.sum;
    otrSum = calcCoin.otrSum;
    notifyListeners();
  }

  initCoinCnt() {
    initState();
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
  var out = [0, 0, 0, 0, 0, 0, 0];
  var minCnt = 10000;
  int c1000 = 0;
  int sum = 0;
  int otrSum = 0;

  calc() {
    c1000 = (value / 1000).toInt();
    sum = 0;
    for (var i = 0; i < 6; i++) {
      sum += coins[i] * coinValues[i] as int;
    }
    if (sum + c1000 * 1000 < value) c1000++;
    dfs(5, coins, 0);
    sum = 0;
    otrSum = 0;
    for (var i = 0; i < 6; i++) {
      sum += out[i] * coinValues[i];
      otrSum += otr[i] * coinValues[i];
    }
    out.add(c1000);
    sum += c1000 * 1000;

    for (var i = 0; i < 6; i++) {
      coins[i] -= out[i];
      coins[i] += otr[i];
    }
  }

  dfs(int coinIndex, coss, sumBf) {
    if (coinIndex < 0) {
      int dif = sumBf + c1000 * 1000 - value;
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
      dfs(coinIndex - 1, coinBf, sumBf + coinValues[coinIndex] * i);
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
    var cState = context.watch<CoinState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Opacity(
              opacity: 0.5,
              child: Text(
                  style: TextStyle(fontSize: 20),
                  '所持枚数: ${cState.coinsCnt()}枚')),
        ),
        Divider(
          thickness: 2,
        ),
        SizedBox(
          height: 8,
        ),
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Card(
            color: Theme.of(context).colorScheme.inversePrimary,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '支払金額: ${cState.costCoinSum}円',
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(
                        child: Opacity(
                          opacity: 0.5,
                          child: Text(
                            textAlign: TextAlign.right,
                            'お釣り: ${cState.otrSum}円',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Row(
                    children: [
                      for (int i = 0; i < 4; i++)
                        Expanded(
                            child: CostCoinUI(
                                value: coinValues[i],
                                cnt: cState.costCoins[i])),
                    ],
                  ),
                  Row(
                    children: [
                      for (int i = 4; i <= 6; i++)
                        Expanded(
                            flex: i == 6 ? 2 : 1,
                            child: CostCoinUI(
                                value: coinValues[i],
                                cnt: cState.costCoins[i])),
                    ],
                  ),
                ],
              ),
            ),
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
    var _bgColor = Theme.of(context).colorScheme.primaryContainer;
    var _txtColor = Theme.of(context).colorScheme.onPrimaryContainer;
    return Opacity(
      opacity: cnt == 0 ? 0.1 : 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          value == 1000
              ? Card(
                  color: _bgColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${value}',
                      style: TextStyle(
                        color: _txtColor,
                        fontSize: 18,
                      ),
                    ),
                  ),
                )
              : CircleAvatar(
                  backgroundColor: _bgColor,
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      color: _txtColor,
                    ),
                  ),
                ),
          Text(
            cnt.toString(),
            style: TextStyle(
              color: _txtColor,
            ),
          ),
        ],
      ),
    );
  }
}

class InputContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cState = context.watch<CoinState>();
    var _controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextButton.icon(
            onPressed: () =>
                {Provider.of<CoinState>(context, listen: false).initCoinCnt()},
            label: Text('リセット'),
            icon: Icon(Icons.restart_alt),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  maxLength: 4,
                  maxLines: 1,
                  controller: _controller,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      icon: Icon(Icons.currency_yen),
                      hintText: "問題の金額",
                      labelText: "金額",
                      suffixIcon: IconButton(
                          onPressed: () => {}, icon: Icon(Icons.clear))),
                  onSubmitted: (value) =>
                      {cState.outCostCoins(int.parse(value))},
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Card(
                    color: Theme.of(context).colorScheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${cState.inValue}円',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}
