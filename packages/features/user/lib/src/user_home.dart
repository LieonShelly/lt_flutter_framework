import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:feature_core/feature_core.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class UserHomePage extends ConsumerStatefulWidget {
  const UserHomePage({super.key});

  @override
  ConsumerState<UserHomePage> createState() {
    return _UserHomePageState();
  }
}

class _UserHomePageState extends ConsumerState<UserHomePage> {
  final List<UserRouteEntity> list = [
    UserRouteEntity(name: 'Chat', routePath: AppRoutePath.chat),
    UserRouteEntity(name: 'Market', routePath: AppRoutePath.market),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildListView()),
      appBar: _buildHeaderView(),
    );
  }

  PreferredSizeWidget _buildHeaderView() {
    return AppBar(
      title: Text(
        "User",
        style: AppTextStyle.feltTipSeniorRegular(
          fontSize: 32,
          color: const Color(0xFF000000),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final elemet = list.elementAt(index);
        return _buildItem(elemet.name, () {
          context.push(elemet.routePath);
        });
      },
    );
  }

  Widget _buildItem(String title, VoidCallback action) {
    final containter = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      decoration: BoxDecoration(
        border: BoxBorder.all(color: AppColors.black1),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Text(
        title,
        style: AppTextStyle.feltTipSeniorRegular(fontSize: 23),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: action,
          borderRadius: BorderRadius.circular(16),
          child: containter,
        ),
      ),
    );
  }
}

class UserRouteEntity {
  final String name;
  final String routePath;

  UserRouteEntity({required this.name, required this.routePath});
}
