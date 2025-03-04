import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wmata_bus/Model/bus_incident.dart';

class IncidentPage extends StatefulWidget {
  const IncidentPage({super.key, required this.incidentList});
  final List<BusIncident> incidentList;

  @override
  State<IncidentPage> createState() => _IncidentPageState();
}

class _IncidentPageState extends State<IncidentPage> {
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildRichText(BuildContext context, String text) {
    final RegExp urlRegex = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );

    List<TextSpan> textSpans = [];
    int lastMatchEnd = 0;

    for (Match match in urlRegex.allMatches(text)) {
      // Add text before the link
      if (match.start > lastMatchEnd) {
        textSpans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: Theme.of(context).textTheme.bodyLarge,
        ));
      }

      // Add the link
      textSpans.add(TextSpan(
        text: match.group(0),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.blue,
          // decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => launchUrl(Uri.parse(match.group(0)!), mode: LaunchMode.externalApplication),
      ));

      lastMatchEnd = match.end;
    }

    // Add remaining text after last link
    if (lastMatchEnd < text.length) {
      textSpans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: Theme.of(context).textTheme.bodyLarge,
      ));
    }

    return RichText(text: TextSpan(children: textSpans));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidents'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: widget.incidentList.isEmpty 
        ? const Center(
            child: Text('No incidents reported'),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: widget.incidentList.length,
            itemBuilder: (context, index) {
              final incident = widget.incidentList[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.incidentType ?? "Unknown Type",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildRichText(context, incident.description ?? ""),
                      if (incident.linesAffected != null)
                        Text(
                          "Lines Affected: ${incident.linesAffected ?? ""}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 8),
                      if (incident.routesAffected != null)
                        Text(
                          "Routes Affected: ${incident.routesAffected?.join(", ") ?? ""}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        "Updated: ${incident.dateUpdated ?? ""}",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
