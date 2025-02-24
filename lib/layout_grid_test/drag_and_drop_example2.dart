import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

void main() {
  runApp(DragAndDropApp());
}

const columnCount = 2;
const rowCount = 2;

class DragAndDropExample extends StatefulWidget {
  const DragAndDropExample({super.key});

  @override
  State<DragAndDropExample> createState() => _DragAndDropExampleState();
}

class _DragAndDropExampleState extends State<DragAndDropExample> {
  // 用于存储每个单元格的内容
  List<List<String>> cellContents = List.generate(
    rowCount,
    (i) => List.generate(columnCount, (j) => 'Cell $i-$j'),
  );

  double getColumnSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth - (columnCount * 2)) /
        columnCount; // 假设每个单元格左右各有一个单位的边距
  }

  double getRowSize(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (screenHeight - (rowCount * 2)) / rowCount; // 假设每个单元格上下各有一个单位的边距
  }

  void swapCellContents(GridPosition from, GridPosition to) {
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
              onMoved: (position) =>
                  swapCellContents(GridPosition(i, j), position),
            ).withGridPlacement(columnStart: i, rowStart: j)
      ],
    );
  }
}

class DraggableCell extends StatelessWidget {
  const DraggableCell({
    super.key,
    required this.content,
    required this.onMoved,
  });

  final String content;
  final Function(GridPosition) onMoved;
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
        onAcceptWithDetails: (details) {
          final from = details.offset.dx ~/ columnSize;
          final to = details.offset.dy ~/ rowSize;
          onMoved(GridPosition(from, to));
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
}

class GridPosition {
  GridPosition(this.x, this.y);
  final int x;
  final int y;
}

class DragAndDropApp extends StatelessWidget {
  const DragAndDropApp({super.key});

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
