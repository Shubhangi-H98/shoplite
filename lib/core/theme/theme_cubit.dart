import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<bool> {
  // false = Light Mode, true = Dark Mode
  ThemeCubit() : super(false);

  void toggleTheme() {
    emit(!state);
  }
}