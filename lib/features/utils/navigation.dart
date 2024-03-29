import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tinycolor2/tinycolor2.dart';

import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../presentation/button.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';
import '../auth/service.dart';

enum NavigationPage { home, profile }

final navigationController = _NavigationPageController();

class _NavigationPageController extends ChangeNotifier {
  bool fullpage = true;

  // ignore: avoid_positional_boolean_parameters
  void setFullpage(bool v) {
    fullpage = v;
    notifyListeners();
  }
}

class NavigationButton extends StatelessWidget {
  final bool includeVerticalPadding;
  const NavigationButton() : includeVerticalPadding = true;
  const NavigationButton.withoutPadding() : includeVerticalPadding = false;

  static const paddingAbove = 15.0;
  static const paddingBelow = 25.0;
  static const size = 50.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: !includeVerticalPadding
            ? 0
            : MediaQuery.of(context).padding.top + paddingAbove,
        bottom: !includeVerticalPadding ? 0 : paddingBelow,
        left: pageHorizontalPadding - 15,
        right: pageHorizontalPadding - 15,
      ),
      child: EntirelyTappable(
        onTap: () {
          navigationController.setFullpage(!navigationController.fullpage);
        },
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Container(
          height: 15,
          child: Assets.menu(),
        ),
      ),
    );
  }
}

class NavigationWrapper extends StatefulWidget {
  final Map<NavigationPage, Widget Function(BuildContext)> pages;
  NavigationWrapper({required this.pages})
      : assert(NavigationPage.values.every(pages.containsKey));

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  var _selectedPage = NavigationPage.home;

  static const _pageVerticalDelta = 25.0;
  static const _pageHorizontalDelta = 270.0;

  Color _backgroundColor(BuildContext context) =>
      AppColors.of(context).darkest.darken(5);
  Color _foregroundColor(BuildContext context) => ColorTween(
        begin: Colors.white,
        end: AppColors.of(context).medium,
      ).lerp(0.1)!;

  @override
  void initState() {
    navigationController.addListener(() {
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.pages[_selectedPage]!(context);
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      tween: Tween<double>(
        begin: 0,
        end: navigationController.fullpage ? 0 : 1,
      ),
      builder: (context, percMenu, _) => _buildContent(context, percMenu, page),
    );
  }

  Widget _buildContent(BuildContext context, double percMenu, Widget page) {
    final infoTop = MediaQuery.of(context).padding.top + 25;
    return Scaffold(
      backgroundColor: _backgroundColor(context),
      body: Stack(children: [
        Positioned(
          top: infoTop,
          child: Container(
            height: MediaQuery.of(context).size.height -
                infoTop -
                MediaQuery.of(context).padding.bottom,
            child: _buildNavigation(context),
          ),
        ),
        _buildRotatingPage(context, percMenu, child: page),
      ]),
    );
  }

  Widget _buildRotatingPage(
    BuildContext context,
    double percMenu, {
    required Widget child,
  }) {
    return Positioned(
      top: percMenu * (MediaQuery.of(context).padding.top + _pageVerticalDelta),
      left: percMenu * _pageHorizontalDelta,
      child: Transform.rotate(
        angle: percMenu * -0.2,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _backgroundColor(context),
                blurRadius: 6,
                spreadRadius: -1,
              )
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: GestureDetector(
            onTap: (percMenu != 0)
                ? () => navigationController.setFullpage(true)
                : null,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: pageHorizontalPadding - 15),
          child: EntirelyTappable(
            onTap: () {
              navigationController.setFullpage(true);
            },
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Icon(
                FontAwesomeIcons.xmark,
                size: 20,
                color: _foregroundColor(context).withOpacity(0.7),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: pageHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Text(
                'Menu',
                style: AppTexts.of(context)
                    .title3
                    .copyWith(color: _foregroundColor(context)),
              ),
              SizedBox(height: 40),
              ...NavigationPage.values.map((e) {
                switch (e) {
                  case NavigationPage.home:
                    return _buildMenuIcon(
                      context,
                      page: NavigationPage.home,
                      icon: FontAwesomeIcons.house,
                      name: 'eventos',
                    );
                  case NavigationPage.profile:
                    return _buildMenuIcon(
                      context,
                      page: NavigationPage.profile,
                      icon: FontAwesomeIcons.solidUser,
                      name: 'meu perfil',
                    );
                }
              }).withBetween(SizedBox(height: 10)),
            ],
          ),
        ),
        Expanded(child: Container()),
        Container(
          padding: const EdgeInsets.only(left: pageHorizontalPadding),
          width: 300,
          child: CustomButton(
            child: Text('Sair'),
            style: AppButton.of(context).largeFilled.copyWith(
                  backgroundColor: MaterialStateProperty.all(
                    AppColors.of(context).darkest,
                  ),
                  foregroundColor: MaterialStateProperty.all(
                    Colors.white,
                  ),
                ),
            onPressed: () {
              _signOut(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuIcon(
    BuildContext context, {
    required NavigationPage page,
    required IconData icon,
    required String name,
  }) {
    final isSelected = page == _selectedPage;
    return EntirelyTappable(
      onTap: isSelected ? null : () => _selectPage(page),
      child: Container(
        decoration: BoxDecoration(
          color: !isSelected
              ? null
              : AppColors.of(context).darkest.darken(10).withOpacity(0.6),
          borderRadius: BorderRadius.circular(15),
        ),
        height: 85,
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: _foregroundColor(context),
            ),
            SizedBox(width: 20),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : null,
                color: _foregroundColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signOut(BuildContext context) async {
    const signOutAction = 1;
    const deleteAccountAction = 2;

    final authService = UserAuthService();
    final response = await showDialog<int>(
      context: context,
      builder: (context) => DialogWrapper(
        child: CustomDialog(
          title: 'Deseja sair?',
          child: Column(
            children: [
              CustomButton(
                child: Text('Sair'),
                onPressed: () => AppRouter.of(context).popDialog(signOutAction),
              ),
              CustomButton(
                child: Text('Excluir minha conta'),
                style: AppButton.of(context).outlined,
                onPressed: () =>
                    AppRouter.of(context).popDialog(deleteAccountAction),
              ),
              CustomButton(
                child: Text('Cancelar'),
                style: AppButton.of(context).outlined,
                onPressed: () => AppRouter.of(context).popDialog(),
              ),
            ],
          ),
        ),
      ),
    );

    if (response == null) return;

    if (response == signOutAction) {
      AppRouter.of(context).pushReplacementSign();
      navigationController.setFullpage(false);
      authService.signOut();
    } else {
      final performAction = await showDialog<bool>(
        context: context,
        builder: (context) => DialogWrapper(
          child: CustomDialog(
            title: 'Excluir sua conta?',
            child: Column(
              children: [
                CustomButton(
                  child: Text('Excluir minha conta'),
                  onPressed: () => AppRouter.of(context).popDialog(true),
                ),
                CustomButton(
                  child: Text('Cancelar'),
                  onPressed: () => AppRouter.of(context).popDialog(false),
                  style: AppButton.of(context).outlined,
                ),
              ],
            ),
          ),
        ),
      );
      if (performAction == true) {
        AppRouter.of(context).pushReplacementSign();
        navigationController.setFullpage(false);
        SuccessMessage.of(context).show('Sua conta foi excluída.');
        await authService.deleteAccount();
      }
    }
  }

  void _selectPage(NavigationPage page) {
    setState(() {
      navigationController.setFullpage(true);
      _selectedPage = page;
    });
  }
}
