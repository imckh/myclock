import 'package:flutter_test_project/flutter_draggable_gridview_test/constants/dimens.dart';
import 'package:flutter/material.dart';

class GridItem extends StatelessWidget {
  const GridItem({required this.image, super.key});
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.paddingSmall,
        vertical: Dimens.paddingSmall,
      ),
      child: Image.asset(
        image,
        fit: BoxFit.cover,
      ),
    );
  }
}
