import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);
  final Locale locale;
  bool get _uk => locale.languageCode == 'uk';

  // Common
  String get save => _uk ? 'Зберегти' : 'Save';
  String get back => _uk ? 'Назад' : 'Back';
  String get apply => _uk ? 'Застосувати' : 'Apply';
  String get cancel => _uk ? 'Скасувати' : 'Cancel';
  String get delete => _uk ? 'Видалити' : 'Delete';
  String get resume => _uk ? 'Продовжити' : 'Resume';
  String get pause => _uk ? 'Пауза' : 'Pause';
  String get all => _uk ? 'Всі' : 'All';
  String get continueLabel => _uk ? 'Далі' : 'Continue';
  String get settings => _uk ? 'Налаштування' : 'Settings';
  String get language => _uk ? 'Мова' : 'Language';

  // Language screen
  String get chooseLanguageTitle => _uk ? 'Оберіть\nмову.' : 'Choose\nyour language.';
  String get chooseLanguageSubtitle => _uk ? 'Ви можете змінити це пізніше в налаштуваннях.' : 'You can change this later in settings.';
  String get langEnglish => 'English';
  String get langUkrainian => 'Українська';

  // Home
  String get yourTrainings => _uk ? 'ВАШІ ТРЕНУВАННЯ' : 'YOUR TRAININGS';
  String get newTraining => _uk ? 'Нове' : 'New';
  String get noTrainingsYet => _uk ? 'Тренувань ще немає.\nНатисніть «Нове», щоб створити перше.' : 'No trainings yet.\nTap New to create your first one.';
  String get exercises => _uk ? 'вправ' : 'exercises';
  String get deleteTrainingTitle => _uk ? 'Видалити тренування?' : 'Delete training?';
  String deleteTrainingBody(String name) => _uk ? 'Видалити "$name" назавжди?' : 'Remove "$name" permanently?';
  String get nothingScheduled => _uk ? 'Нічого не заплановано.' : 'Nothing scheduled.';
  String trainingToday(String name) => _uk ? '$name\nсьогодні.' : '$name\ntoday.';
  String trainingTodayAt(String name, String time) => _uk ? '$name\nо $time.' : '$name\nat $time.';
  String multipleTrainingsToday(int count) => _uk ? '$count тренування\nсьогодні.' : '$count trainings\ntoday.';
  String get notScheduled => _uk ? 'Не заплановано' : 'Not scheduled';
  String get customSchedule => _uk ? 'Власний розклад' : 'Custom schedule';

  // Today date label
  List<String> get weekdayLabels => _uk
      ? ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'НД']
      : ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  List<String> get monthLabels => _uk
      ? ['СІЧ', 'ЛЮТ', 'БЕР', 'КВТ', 'ТРВ', 'ЧРВ', 'ЛИП', 'СРП', 'ВРС', 'ЖВТ', 'ЛСТ', 'ГРД']
      : ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
  Map<int, String> get dayNames => _uk
      ? {1: 'Пн', 2: 'Вт', 3: 'Ср', 4: 'Чт', 5: 'Пт', 6: 'Сб', 7: 'Нд'}
      : {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};

  // Onboarding
  String get step1of2 => _uk ? 'КРОК 1 З 2' : 'STEP 1 OF 2';
  String get pickExercisesTitle => _uk ? 'Виберіть вправи,\nякі ви справді робите.' : 'Pick exercises\nyou actually do.';
  String get pickExercisesSubtitle => _uk ? 'Складіть свою бібліотеку. Пізніше можна додати більше.' : 'Build your personal library. You can always add more later.';
  String get searchExercises => _uk ? 'Пошук вправ' : 'Search exercises';
  String selected(int count) => _uk ? 'Вибрано $count' : '$count selected';

  // Training setup
  String get setupTitle => _uk ? 'Налаштуйте свій\nтренувальний план.' : 'Set up your\ntraining flow.';
  String get setupSubtitle => _uk ? 'Упорядкуйте вправи, виберіть повтори або таймер і налаштуйте відпочинок.' : 'Order exercises, choose reps or timer, and set rest between items.';
  String get trainingName => _uk ? 'Назва тренування' : 'Training name';
  String get scheduleLabel => _uk ? 'Розклад' : 'Schedule';
  String get scheduleOff => _uk ? 'Вимк.' : 'Off';
  String get scheduleCustom => _uk ? 'Власний' : 'Custom';
  String get scheduleNoReminders => _uk ? 'Без нагадувань' : 'No reminders';
  String get schedulePickDays => _uk ? 'Виберіть дні' : 'Pick days';
  String get exercisesHeader => _uk ? 'Вправи' : 'Exercises';
  String get addExercise => _uk ? 'Додати вправу' : 'Add exercise';
  String get editExercise => _uk ? 'Редагувати вправу' : 'Edit exercise';
  String get sets => _uk ? 'Підходи' : 'Sets';
  String get reps => _uk ? 'Повтори' : 'Reps';
  String get timer => _uk ? 'Таймер' : 'Timer';
  String get work => _uk ? 'Робота' : 'Work';
  String get restLabel => _uk ? 'Відпочинок' : 'Rest';
  String get workDuration => _uk ? 'Тривалість роботи' : 'Work duration';
  String get restDuration => _uk ? 'Тривалість відпочинку' : 'Rest duration';
  String get reminder => _uk ? 'Нагадування' : 'Reminder';
  String get reminderTime => _uk ? 'Час нагадування' : 'Reminder time';
  String get daysLabel => _uk ? 'Дні' : 'Days';

  // Training run screen
  String get endSession => _uk ? 'ЗАВЕРШИТИ' : 'END SESSION';
  String get nowLabel => _uk ? 'ЗАРАЗ' : 'NOW';
  String get secondsRemaining => _uk ? 'Секунд залишилось' : 'Seconds remaining';
  String get repsToComplete => _uk ? 'Повторів виконати' : 'Reps to complete';
  String get nextLabel => _uk ? 'ДАЛІ' : 'NEXT';
  String get skipLabel => _uk ? 'Пропустити' : 'Skip';
  String get doneLabel => _uk ? 'Готово' : 'Done';

  // Rest screen
  String get restScreenLabel => _uk ? 'ВІДПОЧИНОК' : 'REST';
  String get endLabel => _uk ? 'КІНЕЦЬ' : 'END';
  String get secondsLabel => _uk ? 'СЕКУНДИ' : 'SECONDS';
  String get nextUpLabel => _uk ? 'ДАЛІ' : 'NEXT UP';
  String get skipRest => _uk ? 'Пропустити відпочинок →' : 'Skip rest →';

  // Done screen
  String get completeLabel => _uk ? 'ВИКОНАНО' : 'COMPLETE';
  String get doneBigLabel => _uk ? 'Готово.' : 'Done.';
  String get totalTime => _uk ? 'ЗАГАЛЬНИЙ ЧАС' : 'TOTAL TIME';
  String get backHome => _uk ? 'На головну' : 'Back home';

  // Settings
  String get soundEffects => _uk ? 'Звукові ефекти' : 'Sound effects';
  String get haptics => _uk ? 'Вібрація' : 'Haptics';
  String get countdownTicks => _uk ? 'Відлік останніх 3 сек' : '3-second ticks';
  String get trainingReminders => _uk ? 'Нагадування про тренування' : 'Training reminders';
  String get soundVolume => _uk ? 'Гучність' : 'Sound volume';
  String get systemTheme => _uk ? 'Системна' : 'System';
  String get lightTheme => _uk ? 'Світла' : 'Light';
  String get darkTheme => _uk ? 'Темна' : 'Dark';
  String get atTime => _uk ? 'За розкладом' : 'At time';
  String get fiveMin => _uk ? '5 хв' : '5 min';
  String get fifteenMin => _uk ? '15 хв' : '15 min';
}
