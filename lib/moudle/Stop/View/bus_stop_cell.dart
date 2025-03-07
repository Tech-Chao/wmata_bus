import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wmata_bus/Model/bus_stop.dart';

class RouteStopCell extends StatelessWidget {
  final BusStop stop;
  final String? atIndex;
  final bool isFavorite;
  final void Function() addFavorite;

  const RouteStopCell({
    super.key,
    required this.stop,
    this.atIndex,
    required this.addFavorite,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (atIndex != null)
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      atIndex!,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      stop.name ?? "",
                      softWrap: true,
                      style: stop.isSelected
                          ? Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w700)
                          : Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.black87,
                              ),
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
          Icons.expand_more_rounded,
          color: Theme.of(context).primaryColor,
          size: 28,
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              "$minutes min",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            if (e.vehicleID != null)
              Text(
                "vehicleID: #${e.vehicleID}",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
                borderRadius: BorderRadius.circular(24),
                onTap: addFavorite,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      key: ValueKey(isFavorite),
                      color: Theme.of(context).primaryColor,
                      size: 30,
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
