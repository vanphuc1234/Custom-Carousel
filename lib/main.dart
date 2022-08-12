import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class ListImage {
  String url;
  double id;
  ListImage({required this.url, required this.id});
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = ScrollController(initialScrollOffset: index);

  List images = [
    ListImage(
        url:
            'https://images.unsplash.com/photo-1514823898861-b1babeb0351d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80',
        id: 0),
    ListImage(
        url:
            'https://images.unsplash.com/photo-1500622944204-b135684e99fd?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1161&q=80',
        id: 1),
    ListImage(
        url:
            'https://images.unsplash.com/photo-1536420124392-79a70082fbe5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=464&q=80',
        id: 2),
    ListImage(
        url:
            'https://images.unsplash.com/photo-1652584466378-2c7313730d3e?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8aGl8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
        id: 3),
    ListImage(
        url:
            'https://images.unsplash.com/photo-1476712395872-c2971d88beb7?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80',
        id: 4)
  ];
  static double index = 0;

  ScrollPhysics? _physics;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      setState(() {
        index = CustomScrollPhysics.currentIndex;
      });

      if (_controller.position.haveDimensions && _physics == null) {
        debugPrint('_controller.position: ${_controller.position}');
        setState(() {
          double dimension =
              _controller.position.maxScrollExtent / (images.length - 1);

          _physics = CustomScrollPhysics(itemDimension: dimension);

          debugPrint('dimension: $dimension');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var maxWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Text('deviceWidth/dimension: $maxWidth'),
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      controller: _controller,
                      physics: _physics,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: images
                              .map((e) => SizedBox(
                                    width: constraints.maxWidth,
                                    height: constraints.maxHeight,
                                    child: Image.network(
                                      e.url,
                                      fit: BoxFit.cover,
                                    ),
                                  ))
                              .toList()),
                    );
                  },
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: Text(
                  '${index.toInt() + 1}/${images.length}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Positioned(
                left: maxWidth * 0.45,
                bottom: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: images
                      .map((e) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _controller.animateTo(
                                    e.id *
                                        _controller.position.maxScrollExtent /
                                        (images.length - 1),
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.fastLinearToSlowEaseIn);
                              });
                              CustomScrollPhysics.currentIndex = e.id;
                              print('jumpToIndex: ${e.id}');
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.fastOutSlowIn,
                                height: index == e.id ? 15 : 8,
                                width: index == e.id ? 15 : 8,
                                padding: const EdgeInsets.all(2),
                                child: CircleAvatar(
                                  backgroundColor:
                                      index == e.id ? Colors.red : Colors.white,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              )
            ],
          )
        ],
      )),
    );
  }

  Color get randomColor =>
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);
}

class CustomScrollPhysics extends ScrollPhysics {
  final double itemDimension;
  static double currentIndex = 0;
  const CustomScrollPhysics(
      {required this.itemDimension, ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(
        itemDimension: itemDimension, parent: buildParent(ancestor)!);
  }

  double getPage(ScrollPosition position) {
    double getPage = position.pixels / itemDimension;
    debugPrint('getPage: $getPage');

    return getPage;
  }

  double getPixels(double page) {
    double getPixels = page * itemDimension;
    debugPrint('getPixels: $getPixels---------------------------------');
    return getPixels;
  }

  double _getTargetPixels(position, Tolerance tolerance, double velocity) {
    double page = getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    currentIndex = page.roundToDouble();
    debugPrint('currentPage: $page');
    return getPixels(page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      debugPrint('velocity: $velocity');
      debugPrint('position.pixels: ${position.pixels}');
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = this.tolerance;

    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
