import 'package:flutter/material.dart';
import 'package:workout_manager/catalog/filter_labels.dart';
import 'package:workout_manager/providers/workout_providers.dart';

Future<CatalogQuery?> showCatalogFilterSheet(
  BuildContext context,
  CatalogQuery currentQuery, {
  required List<String> bodyParts,
  required List<String> equipments,
  required List<String> targets,
}) {
  return showModalBottomSheet<CatalogQuery>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _CatalogFilterSheet(
      initial: currentQuery,
      bodyParts: bodyParts,
      equipments: equipments,
      targets: targets,
    ),
  );
}

class _CatalogFilterSheet extends StatefulWidget {
  final CatalogQuery initial;
  final List<String> bodyParts;
  final List<String> equipments;
  final List<String> targets;

  const _CatalogFilterSheet({
    required this.initial,
    required this.bodyParts,
    required this.equipments,
    required this.targets,
  });

  @override
  State<_CatalogFilterSheet> createState() => _CatalogFilterSheetState();
}

enum _FilterDim { root, bodyPart, equipment, target }

class _CatalogFilterSheetState extends State<_CatalogFilterSheet> {
  late Set<String> _bodyParts;
  late Set<String> _equipments;
  late Set<String> _targets;
  _FilterDim _dim = _FilterDim.root;

  @override
  void initState() {
    super.initState();
    _bodyParts = {...widget.initial.bodyParts};
    _equipments = {...widget.initial.equipments};
    _targets = {...widget.initial.targets};
  }

  CatalogQuery get _query => CatalogQuery(
        search: widget.initial.search,
        bodyParts: _bodyParts,
        equipments: _equipments,
        targets: _targets,
      );

  int get _selectedCount =>
      _bodyParts.length + _equipments.length + _targets.length;

  String get _summary {
    final parts = <String>[
      ..._bodyParts.map(labelBodyPart),
      ..._equipments.map(labelEquipment),
      ..._targets.map(labelTarget),
    ];
    if (parts.isEmpty) return '未选择筛选条件';
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.75;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                if (_dim != _FilterDim.root)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => _dim = _FilterDim.root),
                  ),
                Expanded(
                  child: Text(
                    _dim == _FilterDim.root
                        ? '筛选'
                        : _dim == _FilterDim.bodyPart
                            ? '部位'
                            : _dim == _FilterDim.equipment
                                ? '器械'
                                : '目标肌群',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _bodyParts.clear();
                      _equipments.clear();
                      _targets.clear();
                    });
                  },
                  child: const Text('清空'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _query),
                  child: Text(_selectedCount > 0 ? '完成 ($_selectedCount)' : '完成'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_dim) {
      case _FilterDim.root:
        return ListView(
          children: [
            ListTile(
              title: const Text('部位'),
              subtitle: Text(
                _bodyParts.isEmpty
                    ? '全部'
                    : _bodyParts.map(labelBodyPart).join('、'),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => setState(() => _dim = _FilterDim.bodyPart),
            ),
            ListTile(
              title: const Text('器械'),
              subtitle: Text(
                _equipments.isEmpty
                    ? '全部'
                    : _equipments.map(labelEquipment).join('、'),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => setState(() => _dim = _FilterDim.equipment),
            ),
            ListTile(
              title: const Text('目标肌群'),
              subtitle: Text(
                _targets.isEmpty
                    ? '全部'
                    : _targets.map(labelTarget).join('、'),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => setState(() => _dim = _FilterDim.target),
            ),
          ],
        );
      case _FilterDim.bodyPart:
        return _multiSelect(
          options: widget.bodyParts,
          selected: _bodyParts,
          labelOf: labelBodyPart,
          onChanged: (next) => setState(() => _bodyParts = next),
        );
      case _FilterDim.equipment:
        return _multiSelect(
          options: widget.equipments,
          selected: _equipments,
          labelOf: labelEquipment,
          onChanged: (next) => setState(() => _equipments = next),
        );
      case _FilterDim.target:
        return _multiSelect(
          options: widget.targets,
          selected: _targets,
          labelOf: labelTarget,
          onChanged: (next) => setState(() => _targets = next),
        );
    }
  }

  Widget _multiSelect({
    required List<String> options,
    required Set<String> selected,
    required String Function(String) labelOf,
    required ValueChanged<Set<String>> onChanged,
  }) {
    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (context, i) {
        final key = options[i];
        final checked = selected.contains(key);
        return CheckboxListTile(
          value: checked,
          title: Text(labelOf(key)),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (v) {
            final next = {...selected};
            if (v == true) {
              next.add(key);
            } else {
              next.remove(key);
            }
            onChanged(next);
          },
        );
      },
    );
  }
}
