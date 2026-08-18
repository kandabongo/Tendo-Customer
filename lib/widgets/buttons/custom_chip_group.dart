import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/utils/utils.dart';

class CustomChipGroup<T, V> extends StatelessWidget {
  const CustomChipGroup({
    required this.items,
    required this.labelBuilder,
    this.valueBuilder,
    required this.onChanged,
    required this.selectedItems,
    this.isMultiSelection = true,
    this.wrapAlignment = WrapAlignment.start,
    this.runSpacing = 10,
    this.spacing = 10,
    Key? key,
  }) : super(key: key);

  final List<T> items;
  final String Function(T) labelBuilder;
  final V Function(T)? valueBuilder;
  final Function(List<V>) onChanged;
  final List<V> selectedItems;
  final bool isMultiSelection;
  final WrapAlignment wrapAlignment;
  final double runSpacing;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: wrapAlignment,
      runSpacing: runSpacing,
      spacing: spacing,
      children:
          items.map((item) {
            final V value =
                valueBuilder != null ? valueBuilder!(item) : item as V;
            final bool isSelected = selectedItems.contains(value);
            return ChoiceChip(
              label: Text(
                labelBuilder(item),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColor.primaryColor,
              checkmarkColor: Utils.textColorByPrimaryColor(),
              backgroundColor: Colors.grey.withOpacity(0.1),
              onSelected: (selected) {
                List<V> newSelectedItems = List.from(selectedItems);
                if (isMultiSelection) {
                  if (selected) {
                    newSelectedItems.add(value);
                  } else {
                    newSelectedItems.remove(value);
                  }
                } else {
                  newSelectedItems.clear();
                  if (selected) {
                    newSelectedItems.add(value);
                  }
                }
                onChanged(newSelectedItems);
              },
            );
          }).toList(),
    );
  }
}
