import 'package:wmata_bus/Model/bus_stop.dart';
import 'package:flutter/material.dart';

class FavorCell extends StatelessWidget {
  final BusStop stop;
  const FavorCell({super.key, required this.stop});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      // padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(stop.name ?? "",
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                // Text(stop.stpid != null ? " (${stop.stpid})" : "",
                //     style: Theme.of(context)
                //         .textTheme
                //         .titleSmall),
              ],
            ),
            Row(children: [
              Icon(Icons.directions_bus_rounded,
                  color: Theme.of(context).primaryColor),
              Text(stop.routeID ?? "",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
      ),
    );
  }
}
