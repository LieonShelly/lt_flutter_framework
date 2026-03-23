import 'package:booking/src/search_form/search_form_viewmodel.dart';
import 'package:booking_domain/booking_domain.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:booking/booking.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';

class SearchFormContinent extends StatelessWidget {
  final SearchFormViewModel viewModel;

  const SearchFormContinent({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListenableBuilder(
        listenable: viewModel.load,
        builder: (context, child) {
          if (viewModel.load.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.load.error) {
            return Center(
              child: ErrorIndicator(
                title: Applocalization.of(context).errorWhileLoadingContinents,
                label: Applocalization.of(context).tryAgain,
                onPressed: viewModel.load.execute,
              ),
            );
          }
          return child!;
        },
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) {
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.continents.length,
              padding: Dimens.of(context).edgeInsetsScreenHorizontal,
              itemBuilder: (context, index) {
                final Continent(:imageUrl, :name) = viewModel.continents[index];
                return _CarouselItem(
                  imageUrl: imageUrl,
                  name: name,
                  viewModel: viewModel,
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(width: 8);
              },
            );
          },
        ),
      ),
    );
  }
}

class _CarouselItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final SearchFormViewModel viewModel;

  const _CarouselItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.viewModel,
  });

  bool _selected() =>
      viewModel.selectedContinent == null ||
      viewModel.selectedContinent == name;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorListener: imageErrorListener,
              errorWidget: (context, url, error) {
                return const DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.grey3),
                  child: SizedBox(width: 140, height: 140),
                );
              },
            ),

            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white1,
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _selected() ? 0 : 0.7,
                duration: kThemeChangeDuration,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (viewModel.selectedContinent == name) {
                      viewModel.selectedContinent = null;
                    } else {
                      viewModel.selectedContinent = name;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
