# Ícono del launcher

Coloca aquí tu imagen con el nombre exacto:

    assets/icon/app_icon.png

Requisitos de la imagen:
- Formato PNG (con o sin transparencia).
- Cuadrada, mínimo 512x512 px (ideal 1024x1024 px para buena calidad en todas las densidades).
- Sin bordes redondeados ni máscaras: Android/iOS los recortan automáticamente.

Luego, desde la raíz del proyecto (donde está pubspec.yaml), ejecuta:

    flutter pub get
    flutter pub run flutter_launcher_icons

Esto reemplaza automáticamente los íconos nativos en:
- android/app/src/main/res/mipmap-*/
- ios/Runner/Assets.xcassets/AppIcon.appiconset/
- web/icons/ y web/favicon.png
- windows/runner/resources/app_icon.ico

No necesitas tocar esas carpetas a mano; el paquete las genera todas a partir de esta única imagen.
