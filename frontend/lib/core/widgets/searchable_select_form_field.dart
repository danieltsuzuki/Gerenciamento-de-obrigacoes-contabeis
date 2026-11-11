import 'package:flutter/material.dart';

class SearchableSelectFormField<T> extends FormField<T> {
  final List<T> items;
  final String labelText;
  final String? hintText;
  final String Function(T item) itemLabel;
  final String? Function(T item)? itemSubtitle;
  final bool Function(T item, String query)? filterItem;
  final ValueChanged<T?>? onChanged;
  final Widget? prefixIcon;
  final String modalTitle;
  final String searchHintText;

  SearchableSelectFormField({
    super.key,
    super.initialValue,
    required this.items,
    required this.labelText,
    this.hintText,
    required this.itemLabel,
    this.itemSubtitle,
    this.filterItem,
    this.onChanged,
    super.validator,
    super.enabled = true,
    this.prefixIcon,
    this.modalTitle = 'Selecionar',
    this.searchHintText = 'Pesquisar...',
  }) : super(
          builder: (FormFieldState<T> state) {
            final context = state.context;
            final selectedItem = state.value;

            void openSearchModal() async {
              if (!enabled) return;

              final picked = await showDialog<T>(
                context: context,
                barrierDismissible: true,
                builder: (dialogContext) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: _SearchableSelectModal<T>(
                      items: items,
                      selectedItem: selectedItem,
                      itemLabel: itemLabel,
                      itemSubtitle: itemSubtitle,
                      filterItem: filterItem,
                      title: modalTitle,
                      searchHintText: searchHintText,
                    ),
                  );
                },
              );

              if (picked != null) {
                state.didChange(picked);
                onChanged?.call(picked);
              }
            }

            final displayText = selectedItem != null ? itemLabel(selectedItem) : '';

            return InkWell(
              onTap: enabled ? openSearchModal : null,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: labelText,
                  hintText: hintText ?? 'Selecione...',
                  errorText: state.errorText,
                  border: const OutlineInputBorder(),
                  prefixIcon: prefixIcon,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  enabled: enabled,
                ),
                isEmpty: displayText.isEmpty,
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 15,
                    color: enabled ? Colors.black87 : Colors.black38,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );
}

class _SearchableSelectModal<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final String Function(T item) itemLabel;
  final String? Function(T item)? itemSubtitle;
  final bool Function(T item, String query)? filterItem;
  final String title;
  final String searchHintText;

  const _SearchableSelectModal({
    required this.items,
    required this.selectedItem,
    required this.itemLabel,
    this.itemSubtitle,
    this.filterItem,
    required this.title,
    required this.searchHintText,
  });

  @override
  State<_SearchableSelectModal<T>> createState() => _SearchableSelectModalState<T>();
}

class _SearchableSelectModalState<T> extends State<_SearchableSelectModal<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    if (_query.trim().isEmpty) return widget.items;

    final q = _query.trim().toLowerCase();
    return widget.items.where((item) {
      if (widget.filterItem != null) {
        return widget.filterItem!(item, q);
      }
      final label = widget.itemLabel(item).toLowerCase();
      final subtitle = widget.itemSubtitle?.call(item)?.toLowerCase() ?? '';
      return label.contains(q) || subtitle.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final screenHeight = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 520,
        maxHeight: screenHeight * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  key: const Key('searchable-select-close-button'),
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                key: const Key('searchable-select-search-field'),
                controller: _searchController,
                autofocus: true,
                onChanged: (val) => setState(() => _query = val),
                decoration: InputDecoration(
                  hintText: widget.searchHintText,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
                  ),
                ),
              ),
            ),
            const Divider(height: 16),
            Flexible(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          "Nenhum resultado para '$_query'",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final isSelected = item == widget.selectedItem;
                        final label = widget.itemLabel(item);
                        final subtitle = widget.itemSubtitle?.call(item);

                        return ListTile(
                          key: Key('searchable-select-option-$index'),
                          title: Text(
                            label,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? const Color(0xFF1E3A8A) : Colors.black87,
                            ),
                          ),
                          subtitle: subtitle != null
                              ? Text(subtitle, style: const TextStyle(fontSize: 12))
                              : null,
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Color(0xFF1E3A8A))
                              : null,
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
  }
}

