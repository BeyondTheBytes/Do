import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tinycolor2/tinycolor2.dart';

import '../../config/constants.dart';
import '../../config/state.dart';
import '../../presentation/button.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';
import '../auth/service.dart';

class ProfilePicture extends StatelessWidget {
  final String? url;
  final bool canEdit;
  final bool alternateNoPicture;
  const ProfilePicture({
    required this.url,
    required this.canEdit,
    this.alternateNoPicture = false,
  });

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    return GestureDetector(
      onTap: canEdit ? () => _changeProfilePic(context) : null,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow()],
                image: (url == null)
                    ? null
                    : DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
              ),
              child: (url == null) ? Assets.profilePicture(alternate: alternateNoPicture) : null,
            ),
            if (canEdit)
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).darkest.darken(6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(FontAwesomeIcons.pen, size: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeProfilePic(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => DialogWrapper(
        child: CustomDialog(
          title: 'Permissão de Acesso às Fotos',
          large: false,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Precisamos acessar e armazenar a foto selecionada para alterar a foto de perfil.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        child: Text('Cancelar'),
                        filled: true,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          foregroundColor: MaterialStateProperty.all(AppColors.of(context).medium),
                          side: MaterialStateProperty.all(
                            BorderSide(color: AppColors.of(context).medium, width: 1.5),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        child: Text('Permitir'),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (res != true) return;

    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final controller = EntryController();
    controller.insert(
      context,
      OverlayEntry(
        builder: (context) => Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(200),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              margin: EdgeInsets.only(bottom: 30),
              child: Text(
                'Modificando a imagem de perfil...',
                style: TextStyle(color: Colors.grey[800]),
              ),
            ),
          ),
        ),
      ),
    );

    final authService = UserAuthService();
    try {
      await authService.setProfilePicture(
        AppState.auth.currentUser!.uid,
        File(image.path),
      );
      controller.remove();
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      print('Error: $e');
      controller.remove();
    }
  }
}
