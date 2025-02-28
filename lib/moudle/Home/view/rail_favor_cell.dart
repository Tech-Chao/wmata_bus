import 'package:wmata_bus/Model/rail_route.dart';
import 'package:wmata_bus/Model/rail_station.dart';
import 'package:flutter/material.dart';

class RailFavorCell extends StatelessWidget {
  final RailStation stop;
  const RailFavorCell({super.key, required this.stop});
  @override
  Widget build(BuildContext context) {
    RailRoute railRoute = stop.route!;
    Color routeColor = railRoute.displayName?.toLowerCase() == 'red'
        ? Colors.red
        : railRoute.displayName?.toLowerCase() == 'blue'
            ? Colors.blue
            : railRoute.displayName?.toLowerCase() == 'green'
                ? Colors.green
                : railRoute.displayName?.toLowerCase() == 'yellow'
                    ? Colors.yellow
                    : railRoute.displayName?.toLowerCase() == 'orange'
                        ? Colors.orange
                        : railRoute.displayName?.toLowerCase() == 'silver'
                            ? Colors.grey
                            : Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    stop.name ?? "",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          height: 1.2,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: routeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.train_rounded,
                    color: routeColor,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    railRoute.displayName ?? "",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: routeColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
