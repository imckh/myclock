import 'dart:developer';

import 'package:flutter_test_project/flutter_draggable_gridview_test/constants/images.dart';
import 'package:flutter_test_project/flutter_draggable_gridview_test/widgets/grid_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';

class GridWithScrollControllerExample extends StatefulWidget {
  const GridWithScrollControllerExample({super.key, required this.title});

  final String title;

  @override
  GridWithScrollControllerExampleState createState() =>
      GridWithScrollControllerExampleState();
}

class GridWithScrollControllerExampleState
    extends State<GridWithScrollControllerExample> {
  final List<DraggableGridItem> _listOfDraggableGridItem = [];
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  void initState() {
    _generateImageData();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: DraggableGridViewBuilder(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: MediaQuery.of(context).size.width /
                (MediaQuery.of(context).size.height / 3),
          ),
          children: _listOfDraggableGridItem,
          dragCompletion: onDragAccept,
          isOnlyLongPress: false,
          dragFeedback: feedback,
          dragPlaceHolder: placeHolder,
        ),
      ),
    );
  }

  Widget feedback(List<DraggableGridItem> list, int index) {
    return SizedBox(
      width: 200,
      height: 150,
      child: list[index].child,
    );
  }

  PlaceHolderWidget placeHolder(List<DraggableGridItem> list, int index) {
    return PlaceHolderWidget(
      child: Container(
        color: Colors.white,
      ),
    );
  }

  void onDragAccept(
      List<DraggableGridItem> list, int beforeIndex, int afterIndex) {
    log('onDragAccept: $beforeIndex -> $afterIndex');
  }

  void _generateImageData() {
    _listOfDraggableGridItem.addAll(
      [
        DraggableGridItem(
          child: const GridItem(image: Images.asset_1),
          isDraggable: true,
          dragCallback: (context, isDragging) {
            log('isDragging: $isDragging');
          },
        ),
        DraggableGridItem(
            child: const GridItem(image: Images.asset_2), isDraggable: true),
        DraggableGridItem(
            child: const GridItem(image: Images.asset_3), isDraggable: true),
        DraggableGridItem(
            child: const GridItem(image: Images.asset_4), isDraggable: true),
        DraggableGridItem(
            child: const GridItem(image: Images.asset_5), isDraggable: false),
        DraggableGridItem(
            child: const GridItem(image: Images.asset_6), isDraggable: true),
        DraggableGridItem(
            child: const GridItem(image: Images.asset_7), isDraggable: true),
        DraggableGridItem(
            child: const GridItem(image: Images.asset_8), isDraggable: true),
        DraggableGridItem(
            child: const GridItem(image: Images.asset_9), isDraggable: true),
        DraggableGridItem(
            child: const GridItem(image: Images.asset_10), isDraggable: true),
        DraggableGridItem(
            child: const GridItem(image: Images.asset_11), isDraggable: true),
        DraggableGridItem(
            child: const GridItem(image: Images.asset_12), isDraggable: true),
        DraggableGridItem(
            child: const GridItem(image: Images.asset_13), isDraggable: true),
      ],
    );
  }
}
