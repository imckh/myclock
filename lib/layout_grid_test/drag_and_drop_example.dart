// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

void main() {
  runApp(DragAndDropApp());
}

const columnCount = 4;
const rowCount = 4;

class DragAndDropExample extends StatefulWidget {
  @override
  State<DragAndDropExample> createState() => _DragAndDropExampleState();
}

class _DragAndDropExampleState extends State<DragAndDropExample> {
  /// The [Draggable] and [DragTarget] need to be associated with some type of
  /// data (through their type argument, and `void` doesn't cut it). We keep it
  /// simple and use a key, since we don't actually need to communicate anything
  /// about the dragged data.
  Key draggableKey = UniqueKey();

  /// Current position of the [DraggableGridItem].
  GridPosition draggablePosition = GridPosition(0, 0);

  double getColumnSize(BuildContext context) {
    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    // 计算 columnSize，这里减去一些边距以确保不会超出屏幕
    return (screenWidth - (columnCount * 2)) /
        columnCount; // 假设每个单元格左右各有一个单位的边距
  }

  double getRowSize(BuildContext context) {
    // 获取屏幕高度
    final screenHeight = MediaQuery.of(context).size.height;
    // 计算 rowSize，这里减去一些边距以确保不会超出屏幕
    return (screenHeight - (rowCount * 2)) / rowCount; // 假设每个单元格上下各有一个单位的边距
  }

  void gridItemMoved(GridPosition position) {
    setState(() {
      draggablePosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    final columnSize = getColumnSize(context);
    final rowSize = getRowSize(context);
    return LayoutGrid(
      columnGap: 0,
      rowGap: 0,
      columnSizes: repeat(columnCount, [columnSize.px]),
      rowSizes: repeat(rowCount, [rowSize.px]),
      children: [
        // Fill the grid with a `DragTarget` per cell
        for (int i = 0; i < columnCount; i++)
          for (int j = 0; j < rowCount; j++)
            Cell(
              column: i,
              row: j,
              cellBecameOccupied: gridItemMoved,
            ).withGridPlacement(columnStart: i, rowStart: j),
        // And a single Draggable, positioned according to the
        // `draggablePosition` field.
        DraggableGridItem(
          key: draggableKey,
        ).withGridPlacement(
          columnStart: draggablePosition.x,
          rowStart: draggablePosition.y,
        )
      ],
    );
  }
}

/// A square that can be dragged between grid cells.
class DraggableGridItem extends StatelessWidget {
  const DraggableGridItem({
    required Key key,
  }) : super(key: key);

  double getColumnSize(BuildContext context) {
    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    // 计算 columnSize，这里减去一些边距以确保不会超出屏幕
    return (screenWidth - (columnCount * 2)) /
        columnCount; // 假设每个单元格左右各有一个单位的边距
  }

  double getRowSize(BuildContext context) {
    // 获取屏幕高度
    final screenHeight = MediaQuery.of(context).size.height;
    // 计算 rowSize，这里减去一些边距以确保不会超出屏幕
    return (screenHeight - (rowCount * 2)) / rowCount; // 假设每个单元格上下各有一个单位的边距
  }

  @override
  Widget build(BuildContext context) {
    final columnSize = getColumnSize(context);
    final rowSize = getRowSize(context);
    final square = Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[300]!, Colors.blue[700]!],
        ),
      ),
    );

    return Draggable<Key>(
      data: key,
      feedback: Opacity(
        opacity: 0.6,
        child: Transform.scale(
          scale: 1.2,
          // SizedBox is required here, because the feedback widget isn't bound
          // by a cell and wants to be zero-sized.
          child: SizedBox(
            width: columnSize,
            height: rowSize,
            child: square,
          ),
        ),
      ),
      // Fade a bit for style
      childWhenDragging: Opacity(
        opacity: 0.25,
        child: square,
      ),
      child: square,
    );
  }
}

/// Acts as a position that can be occupied by the [DraggableGridItem] widget.
class Cell extends StatefulWidget {
  const Cell({
    super.key,
    required this.column,
    required this.row,
    required this.cellBecameOccupied,
  });

  final int column;
  final int row;
  final DragTargetAccept<GridPosition> cellBecameOccupied;

  @override
  State<Cell> createState() => _CellState();
}

class _CellState extends State<Cell> {
  bool isDragHovering = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Key>(
      onAcceptWithDetails: (_) {
        setState(() => isDragHovering = false);
        widget.cellBecameOccupied(GridPosition(widget.column, widget.row));
      },
      onMove: (details) => setState(() => isDragHovering = true),
      onLeave: (details) => setState(() => isDragHovering = false),
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: isDragHovering
                ? Border.all(
                    color: Colors.purple[400]!,
                    width: 2,
                  )
                : Border.all(
                    color: Colors.grey[400]!,
                  ),
          ),
        );
      },
    );
  }
}

class GridPosition {
  GridPosition(this.x, this.y);
  final int x;
  final int y;
}

class DragAndDropApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drag and Drop Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(
            child: DragAndDropExample(),
          ),
        ),
      ),
    );
  }
}
