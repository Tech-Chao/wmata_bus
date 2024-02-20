import 'package:wmata_bus/Utils/utils.dart';
import 'package:flutter/material.dart';

class RouteCell extends StatelessWidget {
  final String titile;
  final String subtitle;
  final String routeColor;

  const RouteCell(
      {Key? key,
      required this.titile,
      required this.subtitle,
      required this.routeColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: const EdgeInsets.fromLTRB(15, 20, 15, 0),
      child: ListTile(
          title: Row(children: [
            Icon(Icons.directions_bus_rounded,
                color: Utils.hexToColor(routeColor)),
            const SizedBox(
              width: 10,
            ),
            Text(titile,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.black)),
          ]),
          subtitle:
              Text(subtitle, style: Theme.of(context).textTheme.titleMedium)),
    );
  }
}
