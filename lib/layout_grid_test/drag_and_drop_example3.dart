import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

void main() {
  runApp(DragAndDropApp());
}

const columnCount = 2;
const rowCount = 2;

class DragAndDropExample extends StatefulWidget {
  @override
  State<DragAndDropExample> createState() => _DragAndDropExampleState();
}

class _DragAndDropExampleState extends State<DragAndDropExample> {
  List<List<String>> cellContents = List.generate(
    rowCount,
        (i) => List.generate(columnCount, (j) => 'Cell $i-$j'),
  );

  double getColumnSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth - (columnCount * 2)) / columnCount; // 假设每个单元格左右各有一个单位的边距
  }

  double getRowSize(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (screenHeight - (rowCount * 2)) / rowCount; // 假设每个单元格上下各有一个单位的边距
  }

  void swapCellContents(GridPosition from, GridPosition to) {
    if (from == to) return; // 如果源位置和目标位置相同，则不执行任何操作

    setState(() {
      String temp = cellContents[from.y][from.x];
      cellContents[from.y][from.x] = cellContents[to.y][to.x];
      cellContents[to.y][to.x] = temp;
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
        for (int i = 0; i < columnCount; i++)
          for (int j = 0; j < rowCount; j++)
            DraggableCell(
              content: cellContents[j][i],
              onMoved: (position) => swapCellContents(GridPosition(i, j), position),
              columnSize: columnSize,
              rowSize: rowSize,
            ).withGridPlacement(columnStart: i, rowStart: j)
      ],
    );
  }
}

class DraggableCell extends StatelessWidget {
  const DraggableCell({
    Key? key,
    required this.content,
    required this.onMoved,
    required this.columnSize,
    required this.rowSize,
  }) : super(key: key);

  final String content;
  final Function(GridPosition) onMoved;
  final double columnSize;
  final double rowSize;

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: content,
      feedback: Opacity(
        opacity: 0.6,
        child: Transform.scale(
          scale: 1.2,
          child: SizedBox(
            width: columnSize,
            height: rowSize,
            child: Center(child: Text(content)),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.25,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Center(child: Text(content)),
        ),
      ),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (data) => true,
        onAcceptWithDetails: (data) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final Offset globalPosition = renderBox.localToGlobal(Offset.zero);
          final GridPosition to = findGridPosition(globalPosition, columnSize, rowSize);
          onMoved(to);
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Center(child: Text(content)),
          );
        },
      ),
    );
  }

  GridPosition findGridPosition(Offset offset, double columnSize, double rowSize) {
    int x = (offset.dx / columnSize).floor();
    int y = (offset.dy / rowSize).floor();
    return GridPosition(x, y);
  }
}

class GridPosition {
  GridPosition(this.x, this.y);
  final int x;
  final int y;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is GridPosition && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
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