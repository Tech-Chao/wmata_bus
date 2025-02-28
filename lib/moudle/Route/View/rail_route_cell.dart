import 'package:flutter/material.dart';
import 'package:wmata_bus/Model/rail_route.dart';

class RailRouteCell extends StatelessWidget {
  final RailRoute railRoute;

  const RailRouteCell({Key? key, required this.railRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                            : Colors.blue;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: routeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.directions_railway_filled_outlined,
                color: routeColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Text(railRoute.displayName ?? '',
                style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Theme.of(context).primaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
