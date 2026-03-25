import 'package:cached_network_image/cached_network_image.dart';
import 'package:booking_domain/booking_domain.dart';
import 'package:flutter/material.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:common/common.dart';

class ActivityEntry extends StatelessWidget {
  final Activity activity;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  const ActivityEntry({
    super.key,
    required this.activity,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: activity.imageUrl,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorListener: imageErrorListener,
              errorWidget: (context, url, error) => Container(
                height: 80,
                width: 80,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
              placeholder: (context, url) => Container(
                height: 80,
                width: 80,
                color: Colors.grey[200],
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  activity.timeOfDay.name.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  activity.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          CustomCheckbox(
            key: ValueKey('${activity.ref}-checkbox'),
            value: selected,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
