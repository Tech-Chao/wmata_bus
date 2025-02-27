
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wmata_bus/Model/bus_stop.dart';

class RouteStopCell extends StatelessWidget {
  final BusStop stop;
  final String? atIndex;
  final void Function() addFavorite;

  const RouteStopCell({
    super.key,
    required this.stop,
    this.atIndex,
    required this.addFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (atIndex != null)
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      atIndex!,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      stop.name ?? "",
                      softWrap: true,
                      style: stop.isSelected
                          ? Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold)
                          : Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: cellTrailWidget(context),
                ),
              ],
            ),
            etaInfoWidget(context),
          ],
        ),
      ),
    );
  }

  Widget cellTrailWidget(BuildContext context) {
    if (stop.isLoading) {
      return CupertinoActivityIndicator(
        color: Theme.of(context).primaryColor,
        radius: 12,
      );
    } else {
      return AnimatedRotation(
        turns: stop.predictions != null ? 0.5 : 0,
        duration: const Duration(milliseconds: 300),
        child: Icon(
          Icons.keyboard_arrow_down,
          color: Theme.of(context).primaryColor,
        ),
      );
    }
  }

  Widget etaInfoWidget(BuildContext context) {
    if (stop.predictions == null) {
      return const SizedBox.shrink();
    }

    final busWidgets = stop.predictions!.map((e) {
      final minutes =
          (e.minutes == null || e.minutes! <= 0) ? "0" : e.minutes.toString();
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Text(
              minutes,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 4),
            Text(
              "min",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }).toList();

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: busWidgets.isEmpty
                  ? Text(
                      'No service is scheduled for this stop at this time',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: busWidgets,
                    ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: addFavorite,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      stop.isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(stop.isFavorite),
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
