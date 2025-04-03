import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


class CustomCircleNetworkImage extends StatelessWidget {
  const CustomCircleNetworkImage({
    super.key,
    required this.imageUrl,
    required this.radius,
  });

  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        child: Icon(
          Icons.person,
          size: radius,
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      progressIndicatorBuilder: (context, url, progress) => CircleAvatar(
        radius: radius,
        child: Center(
          child: CircularProgressIndicator(
            value: progress.progress,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        child: Icon(
          Icons.person,
          size: radius,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
