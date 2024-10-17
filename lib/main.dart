import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e, int i) {
              return ReorderableDragStartListener(
                index: i,
                key: Key("$i"),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 48),
                  height: 48,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        Colors.primaries[e.hashCode % Colors.primaries.length],
                  ),
                  child: Center(child: Icon(e, color: Colors.white)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T, int) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DockerStateController>(
      init: DockerStateController<T>(icons: _items),
      builder: (controller) {
        return Container(
          // Height has been limited since ListViews by default always stretch to 100% of their cross axis.
          height: 48 + 16 + 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black12,
          ),
          padding: const EdgeInsets.all(4),
          child: Theme(
            //Change canvas and shadow color to prevent default while flutter background color on the item being dragged.
            data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: Obx(() {
              return ReorderableListView(
                // Change the Proxy widget's elevation to 0 to prevent flutter default elevationon item being dragged
                proxyDecorator: (child, index, animation) => Material(
                  elevation: 0,
                  child: child,
                ),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: false,
                onReorder: controller.reorder,
                children: controller.dockerIconsState
                    .asMap()
                    .keys
                    .toList()
                    .map(
                      (x) => widget.builder(controller.dockerIconsState[x], x),
                    )
                    .toList(),
              );
            }),
          ),
        );
      },
    );
  }
}

/// Controller for the [Dock] that is mainly
/// used to manipulate children of the [Dock]
class DockerStateController<T> extends GetxController {
  RxList dockerIconsState;
  final List<T> icons;

  DockerStateController({required this.icons})
      : dockerIconsState = RxList<T>(icons);

  /// Re-ordering logic used in [ReorderableListView]
  /// to define children position after drag and drop
  ///
  /// [oldIndex] is the previous index of the child <br>
  /// [newIndex] is the new index of the child where it is dropped
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final T item = dockerIconsState.removeAt(oldIndex);
    dockerIconsState.insert(newIndex, item);
  }
}
