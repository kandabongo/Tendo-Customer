import 'package:flutter/material.dart';

class CollapsingSliverAppBar extends StatefulWidget {
  final Color expandedBgColor;
  final Color collapsedBgColor;
  final Widget? title;
  final Widget? leading;
  final Widget flexibleChild;
  final ScrollController scrollController;
  final double collapseThreshold;
  final double expandedHeight;

  const CollapsingSliverAppBar({
    super.key,
    required this.scrollController,
    required this.expandedBgColor,
    required this.collapsedBgColor,
    required this.flexibleChild,
    this.title,
    this.leading,
    this.collapseThreshold = 50,
    this.expandedHeight = 360,
  });

  @override
  State<CollapsingSliverAppBar> createState() => _CollapsingSliverAppBarState();
}

class _CollapsingSliverAppBarState extends State<CollapsingSliverAppBar> {
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final scrolled = widget.scrollController.offset > widget.collapseThreshold;
    if (scrolled != _isCollapsed) {
      setState(() => _isCollapsed = scrolled);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      expandedHeight: widget.expandedHeight,
      backgroundColor:
          _isCollapsed ? widget.collapsedBgColor : widget.expandedBgColor,
      leading: widget.leading,
      title: widget.title,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: widget.expandedBgColor,
          child: widget.flexibleChild,
        ),
      ),
    );
  }
}
