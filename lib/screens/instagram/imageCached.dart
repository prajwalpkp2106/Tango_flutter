import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String? imageURL;
  const CachedImage(this.imageURL, {super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final placeholder =
        'assets/images/profiles.jpg'; // Path to your default image

    return imageURL != null
        ? CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: imageURL!,
            progressIndicatorBuilder: (context, url, progress) {
              return Padding(
                padding: EdgeInsets.all(mediaQuery.size.height * 0.15),
                child: CircularProgressIndicator(
                  value: progress.progress,
                  color: Colors.black,
                ),
              );
            },
            errorWidget: (context, url, error) => Container(
              color: Colors.amber,
            ),
          )
        : Image.asset(
            placeholder,
            fit: BoxFit.cover,
          );
  }
}
