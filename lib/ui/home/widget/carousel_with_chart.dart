import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CarouselWithChart extends StatefulWidget {
  final List<Widget> carouselItems;
  final IconData infoIcon;
  final bool autoPlay;
  final bool enableInfiniteScroll;
  final double viewportFraction;

  const CarouselWithChart({
    super.key,
    required this.carouselItems,
    this.infoIcon = Icons.remove_red_eye,
    this.autoPlay = false,
    this.enableInfiniteScroll = false,
    this.viewportFraction = 1,
  });

  @override
  _CarouselWithChartState createState() => _CarouselWithChartState();
}

class _CarouselWithChartState extends State<CarouselWithChart> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CarouselSlider(
          items: [
            ...widget.carouselItems,
          ],
          options: CarouselOptions(
            height: 400,
            enlargeCenterPage: true,
            enlargeFactor: 0.12,
            enableInfiniteScroll: widget.enableInfiniteScroll,
            animateToClosest: false,
            scrollDirection: Axis.horizontal,
            autoPlay: widget.autoPlay,
            viewportFraction: widget.viewportFraction,
            pageSnapping: true,
            scrollPhysics: const BouncingScrollPhysics(),
            onPageChanged: (index, reason) {
              setState(() {
                activeIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSmoothIndicator(
          activeIndex: activeIndex,
          count: widget.carouselItems.length + 1, // Inclut la page info
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor:  Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            dotColor: Colors.grey,
          ),
        ),
      ],
    );
  }


}