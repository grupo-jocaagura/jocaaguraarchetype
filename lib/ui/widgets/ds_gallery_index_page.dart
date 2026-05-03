part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Shows the internal index of the Design System gallery.
class DsGalleryIndexPage extends StatelessWidget {
  const DsGalleryIndexPage({
    required this.state,
    required this.onGoTo,
    super.key,
  });

  final ModelDsGalleryState state;
  final ValueChanged<int> onGoTo;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<ModelDsGalleryPageEntry>> sections =
        state.pagesBySection;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Gallery Index'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: sections.entries.map(
          (MapEntry<String, List<ModelDsGalleryPageEntry>> section) {
            return _DsGalleryIndexSection(
              title: section.key,
              pages: section.value,
              state: state,
              onGoTo: onGoTo,
            );
          },
        ).toList(growable: false),
      ),
    );
  }
}

class _DsGalleryIndexSection extends StatelessWidget {
  const _DsGalleryIndexSection({
    required this.title,
    required this.pages,
    required this.state,
    required this.onGoTo,
  });

  final String title;
  final List<ModelDsGalleryPageEntry> pages;
  final ModelDsGalleryState state;
  final ValueChanged<int> onGoTo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            for (final ModelDsGalleryPageEntry page in pages)
              _DsGalleryIndexTile(
                page: page,
                index: state.indexOfPage(page),
                isSelected: state.currentPage?.id == page.id,
                onGoTo: onGoTo,
              ),
          ],
        ),
      ),
    );
  }
}

class _DsGalleryIndexTile extends StatelessWidget {
  const _DsGalleryIndexTile({
    required this.page,
    required this.index,
    required this.isSelected,
    required this.onGoTo,
  });

  final ModelDsGalleryPageEntry page;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onGoTo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      contentPadding: EdgeInsets.zero,
      title: Text(page.title),
      subtitle: page.description.isEmpty ? null : Text(page.description),
      leading: CircleAvatar(
        child: Text('${index + 1}'),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: index < 0 ? null : () => onGoTo(index),
    );
  }
}
