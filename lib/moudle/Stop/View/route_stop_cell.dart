import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wmata_bus/Model/bus_stop.dart';

class RouteStopCell extends StatelessWidget {
  final BusStop stop;
  final void Function() addFavorite;

  const RouteStopCell({
    super.key,
    required this.stop,
    required this.addFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text("${stop.stopSequence ?? ""}. ${stop.stopName ?? ""}",
                      style: stop.isSelected
                          ? Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)
                          : Theme.of(context).textTheme.titleMedium),
                ),
                cellTrailWidget(context)
              ],
            ),
            etaInfoWidget(context),
          ],
        ),
      ),
    );
  }

  Widget cellTrailWidget(context) {
    if (stop.isLoading) {
      return CupertinoActivityIndicator(
          color: Theme.of(context).primaryColor, radius: 10);
    } else if (stop.predictions != null) {
      return const Icon(Icons.keyboard_arrow_up);
    } else {
      return const Icon(Icons.keyboard_arrow_down);
    }
  }

  Widget etaInfoWidget(context) {
// 未选中或者无数据
    if (stop.predictions == null) {
      return Container();
    }
    Color primaryColor = Theme.of(context).primaryColor;
    List<Widget> busWidget = stop.predictions!
        .map((e) => SizedBox(
              height: 45,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    e.waitinMins.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(color: Theme.of(context).primaryColor),
                  ),
                  Text(" min", style: Theme.of(context).textTheme.titleSmall)
                ],
              ),
            ))
        .toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SizedBox(
        height: max(50, busWidget.length * 45),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            busWidget.isEmpty
                ? Expanded(
                    child: Text(
                        'No service is scheduled for this stop at this time',
                        style: Theme.of(context).textTheme.titleSmall),
                  )
                : Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: busWidget),
                  ),
            GestureDetector(
              onTap: () async {
                addFavorite();
              },
              behavior: HitTestBehavior.translucent, // 让点击区域包括空白部分
              child: Padding(
                  padding: const EdgeInsets.all(10.0), // 可根据需要调整内边距
                  child: Icon(
                    (stop.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border_outlined),
                    color: primaryColor,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
