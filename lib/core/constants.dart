import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:elderly_prototype_app/core/localization/app_language.dart';
import 'package:elderly_prototype_app/core/localization/language_controller.dart';

class AppStrings {
  /// Returns [en] or [tr] depending on the currently active language.
  /// This is the one helper every localized string in this class uses —
  /// existing call sites (AppStrings.xxx) never need to change, only the
  /// definitions here do.
  static String _t({required String en, required String tr}) {
    return AppLanguageController.current == AppLanguage.turkish ? tr : en;
  }

  static String get appTitle =>
      _t(en: 'Elderly Care App', tr: 'Yaşlı Bakım Uygulaması');
  static String get fitnessTitle =>
      _t(en: 'Daily Exercises', tr: 'Günlük Egzersizler');
  static String get filterAll => _t(en: 'All', tr: 'Tümü');
  static String get exercisesCompleted =>
      _t(en: 'exercises completed', tr: 'egzersiz tamamlandı');
  static String get nextWorkoutTitle =>
      _t(en: 'Next Workout', tr: 'Sıradaki Egzersiz');
  static String get startWorkout =>
      _t(en: 'Start Workout', tr: 'Egzersize Başla');
  static String get setsCompleted =>
      _t(en: 'Sets Completed:', tr: 'Tamamlanan Setler:');

  // --- Start Emergency / SOS Feature ---
  static String get sosTitle =>
      _t(en: 'Send Emergency Alert', tr: 'Acil Durum Uyarısı Gönder');
  static String get sosCancelButton =>
      _t(en: 'I AM SAFE / CANCEL', tr: 'GÜVENDEYİM / İPTAL');
  static String get sosSendingAlert =>
      _t(en: 'Sending Alert in...', tr: 'Uyarı gönderiliyor...');

  // Settings & Contacts
  static String get sosSettingsTitle =>
      _t(en: 'Emergency Contacts', tr: 'Acil Durum Kişileri');
  static String get sosSettingsSubtitle => _t(
      en: 'Manage who to call in emergency',
      tr: 'Acil durumda kimin aranacağını yönetin');
  static String get addContactTitle =>
      _t(en: 'Add New Contact', tr: 'Yeni Kişi Ekle');
  static String get editContactTitle =>
      _t(en: 'Edit Contact', tr: 'Kişiyi Düzenle');
  static String get contactNameHint => _t(en: 'Contact Name', tr: 'Kişi Adı');
  static String get contactPhoneHint => _t(
      en: 'Phone Number (e.g., +90555...)',
      tr: 'Telefon Numarası (örn. +90555...)');
  static String get isPrimaryLabel =>
      _t(en: 'Set as Primary Contact', tr: 'Birincil Kişi Olarak Ayarla');
  static String get isPrimaryHint => _t(
      en: 'This person will be called automatically.',
      tr: 'Bu kişi otomatik olarak aranacaktır.');
  static String get saveLabel => _t(en: 'Save Contact', tr: 'Kişiyi Kaydet');
  static String get deleteLabel => _t(en: 'Delete', tr: 'Sil');

  // Messages
  static String get emergencyAlertMessage => _t(
      en: 'HELP! \nI have an emergency. \nMy location: ',
      tr: 'YARDIM! \nAcil bir durumum var. \nKonumum: ');
  static String get validationName =>
      _t(en: 'Please enter a name', tr: 'Lütfen bir isim girin');
  static String get validationPhone => _t(
      en: 'Please enter a phone number',
      tr: 'Lütfen bir telefon numarası girin');
  static String get noContacts => _t(
      en: 'No emergency contacts added yet.',
      tr: 'Henüz acil durum kişisi eklenmedi.');
  //--- Ends Emergency / SOS Feature ---

  //--- Start of Exercise Feature ---
  // ⭐️ ADDED: Strings for the detail screen of Exercise
  static String get steps => _t(en: 'Steps', tr: 'Adımlar');
  static String get exerciseTimer =>
      _t(en: 'Exercise Timer', tr: 'Egzersiz Zamanlayıcısı');
  static String get markComplete =>
      _t(en: 'Mark as Complete', tr: 'Tamamlandı Olarak İşaretle');
  static String get markIncomplete =>
      _t(en: 'Mark as Incomplete', tr: 'Tamamlanmadı Olarak İşaretle');
  static String get close => _t(en: 'Close', tr: 'Kapat');
  static String get minutesShort => _t(en: 'min', tr: 'dk');
  static String get difficultyEasy => _t(en: 'Easy', tr: 'Kolay');
  static String get difficultyMedium => _t(en: 'Medium', tr: 'Orta');
  static String get difficultyHard => _t(en: 'Hard', tr: 'Zor');
  //--- End of Exercise Feature ---

  //--- Start of Health Tracking Feature ---
  static String get healthTitle =>
      _t(en: 'Health Tracking', tr: 'Sağlık Takibi');
  static String get bloodPressure => _t(en: 'Blood Pressure', tr: 'Tansiyon');
  static String get bloodSugar => _t(en: 'Blood Sugar', tr: 'Kan Şekeri');
  static String get weight => _t(en: 'Weight', tr: 'Kilo');
  static String get sleep => _t(en: 'Sleep', tr: 'Uyku');
  static String get heartRate => _t(en: 'Heart Rate', tr: 'Nabız');
// static String get steps

// Units
  static String get unitBP => _t(en: 'mmHg', tr: 'mmHg');
  static String get unitSugar => _t(en: 'mg/dL', tr: 'mg/dL');
  static String get unitWeight => _t(en: 'kg', tr: 'kg');
  static String get unitSleep => _t(en: 'hours', tr: 'saat');
  static String get unitHeart => _t(en: 'bpm', tr: 'bpm');
  static String get unitSteps => _t(en: 'steps', tr: 'adım');

// Status
  static String get statusNormal => _t(en: 'Normal', tr: 'Normal');
  static String get statusWarning => _t(en: 'Attention', tr: 'Dikkat');
  static String get statusCritical => _t(en: 'Critical', tr: 'Kritik');

// Time Ranges
  static String get week => _t(en: 'Week', tr: 'Hafta');
  static String get month => _t(en: 'Month', tr: 'Ay');
  static String get year => _t(en: 'Year', tr: 'Yıl');

// Chart & History
  static String get noData => _t(en: 'No records yet.', tr: 'Henüz kayıt yok.');
  static String get recentHistory => _t(en: 'Recent History', tr: 'Son Geçmiş');
  static String get addRecord => _t(en: 'Add Record', tr: 'Kayıt Ekle');
  static String get sys => _t(en: 'Systolic', tr: 'Büyük Tansiyon');
  static String get dia => _t(en: 'Diastolic', tr: 'Küçük Tansiyon');
  //--- End of Health Tracking Feature ---

  // --- Start of Water Reminder Feature ---
  static String get waterTitle =>
      _t(en: 'Water Reminder', tr: 'Su Hatırlatıcı');
  static String get goalLabel => _t(en: 'Goal:', tr: 'Hedef:');
  static String get goalAchieved =>
      _t(en: '🎉 Great job! Goal achieved!', tr: '🎉 Harika! Hedefe ulaşıldı!');
  static String get remindersTitle => _t(en: 'Reminders', tr: 'Hatırlatıcılar');
  static String get every => _t(en: 'Every', tr: 'Her');
  static String get hoursSuffix => _t(en: 'hour(s)', tr: 'saatte bir');
  static String get disabled => _t(en: 'Disabled', tr: 'Kapalı');
  static String get changeSettings =>
      _t(en: 'Change Settings', tr: 'Ayarları Değiştir');
  static String get addWaterTitle => _t(en: 'Add Water', tr: 'Su Ekle');
  static String get noWaterLogged =>
      _t(en: 'No water logged today', tr: 'Bugün su kaydı yok');
  static String get todaysWater => _t(en: "Today's Water", tr: 'Bugünkü Su');
  static String get settingsTitle => _t(en: 'Settings', tr: 'Ayarlar');
  static String get remindMeEvery =>
      _t(en: 'Remind me every:', tr: 'Bana şu sıklıkla hatırlat:');
  static String get activeHoursTitle => _t(
      en: 'Active Hours (No sleep disturbance):',
      tr: 'Aktif Saatler (Uykuyu bölmez):');
  static String get vibrationTitle => _t(en: 'Vibration', tr: 'Titreşim');
  static String get vibrationSubtitle =>
      _t(en: 'Vibrate on reminder', tr: 'Hatırlatmada titreşim');
  static String get saveButton => _t(en: 'Save', tr: 'Kaydet');
  // --- End of Water Reminder Feature ---

  // --- Start of chatbot Feature ---
  static String get chatbotTitle =>
      _t(en: "AI Assistant", tr: "Yapay Zeka Asistanı");
  static String get askSomething =>
      _t(en: "Type your question here...", tr: "Sorunuzu buraya yazın...");
  static String get chatError => _t(
      en: "I'm having trouble connecting. Try again?",
      tr: "Bağlanmakta sorun yaşıyorum. Tekrar deneyeyim mi?");
  // --- End of chatbot Feature ---

  // --- Start Memory Match Games Feature ---
  static String get brainGamesTitle =>
      _t(en: 'Brain Games', tr: 'Zeka Oyunları');
  static String get memoryMatchTitle =>
      _t(en: 'Memory Match', tr: 'Hafıza Eşleştirme');
  static String get memoryMatchDesc => _t(
      en: 'Find the matching pairs to keep your mind sharp.',
      tr: 'Zihninizi keskin tutmak için eşleşen çiftleri bulun.');
  static String get movesCounter => _t(en: 'Moves:', tr: 'Hamle:');
  static String get timeCounter => _t(en: 'Time:', tr: 'Süre:');
  static String get pairsFound => _t(en: 'Pairs Found:', tr: 'Bulunan Çift:');
  static String get wellDone => _t(en: 'Well Done!', tr: 'Aferin!');
  static String get gameCompleteMsg =>
      _t(en: 'You found all the matches!', tr: 'Tüm eşleşmeleri buldunuz!');
  static String get playAgain => _t(en: 'Play Again', tr: 'Tekrar Oyna');
  static String get quitGame => _t(en: 'Quit', tr: 'Çık');
  static String get statsTitle => _t(en: 'Your Progress', tr: 'İlerlemeniz');
  static String get bestTime => _t(en: 'Best Time', tr: 'En İyi Süre');
  static String get totalGames =>
      _t(en: 'Total Games Played', tr: 'Toplam Oynanan Oyun');
  static String get wordSearchTitle =>
      _t(en: 'Word Search', tr: 'Kelime Bulmaca');
  static String get sudokuTitle => _t(en: 'Sudoku', tr: 'Sudoku');
  static String get comingSoon => _t(en: 'Coming Soon', tr: 'Yakında');
  static String get continueGame =>
      _t(en: 'Continue Next Level', tr: 'Sonraki Seviyeye Devam Et');
  static String get level => _t(en: 'Level', tr: 'Seviye');
  static String get totalTimeLabel =>
      _t(en: 'Total Time Spent:', tr: 'Toplam Geçirilen Süre:');
  static String get avgTimeLabel =>
      _t(en: 'Average Time:', tr: 'Ortalama Süre:');
  static String get bestTimeLabel =>
      _t(en: 'Fastest Win:', tr: 'En Hızlı Kazanma:');
  static String get totalWinsLabel =>
      _t(en: 'Total Wins:', tr: 'Toplam Kazanma:');
  static String get noStatsYet => _t(
      en: 'Play a game to see your stats!',
      tr: 'İstatistiklerinizi görmek için bir oyun oynayın!');
  // --- End Memory match Feature ---

  // --- Start Word Search Feature ---
  static String get wordSearchDesc => _t(
      en: 'Find the hidden words to train your focus.',
      tr: 'Odaklanmanızı geliştirmek için gizli kelimeleri bulun.');
  static String get wordsRemaining =>
      _t(en: 'Words Remaining:', tr: 'Kalan Kelime:');
  static String get wordsFound => _t(en: 'Words Found:', tr: 'Bulunan Kelime:');
  static String get tapFirstTapLast => _t(
      en: 'Tap the first letter, then tap the last letter of a word.',
      tr: 'Bir kelimenin ilk harfine, sonra son harfine dokunun.');

  // Localized Word Categories (Easy, Medium, Hard)
  static const List<String> easyWords = [
    'CAT',
    'DOG',
    'BIRD',
    'FISH',
    'COW',
    'APPLE',
    'PLUM',
    'PEAR',
    'MILK',
    'TEA',
    'SUN',
    'MOON',
    'STAR',
    'TREE',
    'LEAF',
    'HOME',
    'BED',
    'SOFA',
    'BOOK',
    'PEN'
  ];

  static const List<String> mediumWords = [
    'RABBIT',
    'TURTLE',
    'MONKEY',
    'SPIDER',
    'BANANA',
    'ORANGE',
    'GRAPES',
    'CHERRY',
    'COFFEE',
    'WATER',
    'FLOWER',
    'GARDEN',
    'FOREST',
    'RIVER',
    'WINDOW',
    'MIRROR',
    'FAMILY',
    'DOCTOR',
    'NURSE',
    'HEALTH'
  ];

  static const List<String> hardWords = [
    'ELEPHANT',
    'KANGAROO',
    'CROCODILE',
    'PINEAPPLE',
    'STRAWBERRY',
    'WATERMELON',
    'BREAKFAST',
    'MEDICINE',
    'HOSPITAL',
    'AMBULANCE',
    'MOUNTAIN',
    'WATERFALL',
    'COMMUNITY',
    'ADVENTURE',
    'TELEVISION',
    'NEWSPAPER',
    'FURNITURE'
  ];
  // --- End Word Search Feature ---

  // --- Start Sudoku Game Feature ---
  static String get sudokuDesc => _t(
      en: 'Fill the grid with numbers without repeating them in rows, columns, or blocks.',
      tr: 'Izgarayı, satır, sütun veya bloklarda tekrar etmeyecek şekilde sayılarla doldurun.');
  static String get hintsUsed => _t(en: 'Hints Used:', tr: 'Kullanılan İpucu:');
  static String get hintButton => _t(en: 'Hint', tr: 'İpucu');
  static String get eraseButton => _t(en: 'Erase', tr: 'Sil');
  static String get sudokuInstructions => _t(
      en: 'Tap an empty square, then pick a number.',
      tr: 'Boş bir kareye dokunun, ardından bir sayı seçin.');
  // --- End Sudoku Game Feature ---

  // --- Start Nearby Services Hub Feature ---
  static String get nearbyServicesTitle =>
      _t(en: 'Nearby Services', tr: 'Yakındaki Hizmetler');
  static String get nearbyServicesGridSubtitle => _t(
      en: 'Bus stops, hospitals & markets',
      tr: 'Duraklar, hastaneler ve pazarlar');
  static String get nearbyServicesHubSubtitle => _t(
      en: 'Find help and places close to you',
      tr: 'Size yakın yardım ve yerleri bulun');
  static String get nearbyHospitalsTitle =>
      _t(en: 'Nearby Hospitals', tr: 'Yakındaki Hastaneler');
  static String get nearbyMarketsTitle =>
      _t(en: 'Nearby Markets', tr: 'Yakındaki Pazarlar');
  static String get comingSoonLabel => _t(en: 'Coming Soon', tr: 'Yakında');
  static String get comingSoonMessage => _t(
      en: 'This feature will be available soon.',
      tr: 'Bu özellik yakında kullanıma sunulacaktır.');
  // --- End Nearby Services Hub Feature ---

  // --- Start Nearby Bus Stops Feature ---
  static String get nearbyBusStopsTitle =>
      _t(en: 'Nearby Bus Stops', tr: 'Yakındaki Otobüs Durakları');
  static String get nearbyBusStopsSubtitle =>
      _t(en: 'Find buses close to you', tr: 'Size yakın otobüsleri bulun');
  static String get locatingMessage =>
      _t(en: 'Finding your location...', tr: 'Konumunuz bulunuyor...');
  static String get busStopsFoundLabel =>
      _t(en: 'closest stops near you', tr: 'size en yakın duraklar');
  static String get getDirectionsButton =>
      _t(en: 'Get Directions', tr: 'Yol Tarifi Al');
  static String get retryButton => _t(en: 'Try Again', tr: 'Tekrar Dene');
  static String get openLocationSettingsButton =>
      _t(en: 'Open Location Settings', tr: 'Konum Ayarlarını Aç');
  static String get openAppSettingsButton =>
      _t(en: 'Open App Settings', tr: 'Uygulama Ayarlarını Aç');
  static String get locationServiceDisabledMessage => _t(
      en: 'Location is turned off on your phone. Please turn it on to find bus stops near you.',
      tr: 'Telefonunuzda konum kapalı. Yakınınızdaki durakları bulmak için lütfen açın.');
  static String get locationPermissionDeniedMessage => _t(
      en: 'This app needs permission to see your location to find nearby bus stops.',
      tr: 'Yakındaki durakları bulmak için bu uygulamanın konumunuzu görmesine izin vermeniz gerekir.');
  static String get locationPermissionDeniedForeverMessage => _t(
      en: 'Location permission was denied. Please allow it from your phone settings to use this feature.',
      tr: 'Konum izni reddedildi. Bu özelliği kullanmak için lütfen telefon ayarlarınızdan izin verin.');
  static String get busStopsGenericError => _t(
      en: 'Something went wrong while loading bus stops. Please try again.',
      tr: 'Duraklar yüklenirken bir sorun oluştu. Lütfen tekrar deneyin.');
  static String get busStopsDataUnavailableMessage => _t(
      en: 'Could not load bus stop information. Please check your internet connection and try again.',
      tr: 'Durak bilgileri yüklenemedi. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.');
  static String get noBusStopsFound =>
      _t(en: 'No bus stops found nearby.', tr: 'Yakında durak bulunamadı.');
  static String get directionsErrorMessage => _t(
      en: 'Could not open Maps. Please make sure a maps app is installed.',
      tr: 'Harita açılamadı. Lütfen bir harita uygulaması yüklü olduğundan emin olun.');
  static String get lastUpdatedLabel =>
      _t(en: 'Last updated', tr: 'Son güncelleme');
  // --- End Nearby Bus Stops Feature ---

  // --- Start Nearby Healthcare Feature ---
  static String get nearbyHealthcareTitle =>
      _t(en: 'Nearby Healthcare', tr: 'Yakındaki Sağlık Hizmetleri');
  static String get nearbyHealthcareHubSubtitle => _t(
      en: 'Find hospitals, health centers and open pharmacies close to you',
      tr: 'Size yakın hastane, sağlık merkezi ve açık eczaneleri bulun');
  static String get callButton => _t(en: 'Call', tr: 'Ara');
  static String get emergencyBannerText => _t(
      en: 'Medical emergency? Call 112 now.',
      tr: "Tıbbi acil durum mu? Hemen 112'yi arayın.");
  static String get emergencyCallButton => _t(en: 'Call 112', tr: "112'yi Ara");
  static String get categoryAll => _t(en: 'All', tr: 'Tümü');
  static String get categoryHospitals => _t(en: 'Hospitals', tr: 'Hastaneler');
  static String get categoryFamilyHealthCenters =>
      _t(en: 'Health Centers', tr: 'Sağlık Merkezleri');
  static String get categoryPharmacies =>
      _t(en: 'Open Pharmacies', tr: 'Açık Eczaneler');
  static String get openNowBadge => _t(en: 'Open Now', tr: 'Şu An Açık');
  static String get searchHealthcareHint =>
      _t(en: 'Search by name...', tr: 'İsme göre ara...');
  static String get noHealthcareResultsFound => _t(
      en: 'No healthcare facilities found nearby.',
      tr: 'Yakında sağlık kuruluşu bulunamadı.');
  static String get locatingHealthcareMessage =>
      _t(en: 'Finding your location...', tr: 'Konumunuz bulunuyor...');
  static String get healthcareResultsFoundLabel =>
      _t(en: 'closest to you', tr: 'size en yakın');
  static String get healthcareDataUnavailableMessage => _t(
      en: 'Could not load healthcare facility information. Please check your internet connection and try again.',
      tr: 'Sağlık kuruluşu bilgileri yüklenemedi. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.');
  static String get healthcareGenericError => _t(
      en: 'Something went wrong while loading healthcare facilities. Please try again.',
      tr: 'Sağlık kuruluşları yüklenirken bir sorun oluştu. Lütfen tekrar deneyin.');
  static String get callErrorMessage => _t(
      en: 'Could not start the call. Please dial the number manually.',
      tr: 'Arama başlatılamadı. Lütfen numarayı elle çevirin.');
  // --- End Nearby Healthcare Feature ---

  // --- Start Nearby Markets Feature ---
  static String get marketsHubSubtitle => _t(
      en: 'Find supermarkets, grocers, bakeries, and weekly bazaars close to you',
      tr: 'Size yakın market, bakkal, fırın ve semt pazarlarını bulun');
  static String get categorySupermarkets =>
      _t(en: 'Supermarkets', tr: 'Marketler');
  static String get categoryGroceryConvenience =>
      _t(en: 'Grocery & Convenience', tr: 'Bakkal ve Market');
  static String get categoryBakeries => _t(en: 'Bakeries', tr: 'Fırınlar');
  static String get categoryButchers => _t(en: 'Butchers', tr: 'Kasaplar');
  static String get categoryGreengrocers =>
      _t(en: 'Greengrocers', tr: 'Manavlar');
  static String get categoryWeeklyBazaars =>
      _t(en: 'Weekly Bazaars', tr: 'Semt Pazarları');
  static String get searchMarketsHint =>
      _t(en: 'Search by name...', tr: 'İsme göre ara...');
  static String get noMarketsResultsFound => _t(
      en: 'No markets found nearby.', tr: 'Yakında pazar/market bulunamadı.');
  static String get locatingMarketsMessage =>
      _t(en: 'Finding your location...', tr: 'Konumunuz bulunuyor...');
  static String get marketsResultsFoundLabel =>
      _t(en: 'closest to you', tr: 'size en yakın');
  static String get marketsDataUnavailableMessage => _t(
      en: 'Could not load market information. Please check your internet connection and try again.',
      tr: 'Pazar bilgileri yüklenemedi. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.');
  static String get marketsGenericError => _t(
      en: 'Something went wrong while loading markets. Please try again.',
      tr: 'Pazarlar yüklenirken bir sorun oluştu. Lütfen tekrar deneyin.');
  static String get shopsPartialFailureMessage => _t(
      en: 'Supermarkets, bakeries, and other shops could not be loaded right now. Weekly bazaars are still shown below. Pull down to try again.',
      tr: "Marketler, fırınlar ve diğer dükkanlar şu anda yüklenemedi. Semt pazarları aşağıda gösterilmeye devam ediyor. Tekrar denemek için aşağı çekin.");
  static String get weeklyBazaarFallbackBadge =>
      _t(en: 'Weekly Market', tr: 'Haftalık Pazar');
  static String get dayMonShort => _t(en: 'Mon', tr: 'Pzt');
  static String get dayTueShort => _t(en: 'Tue', tr: 'Sal');
  static String get dayWedShort => _t(en: 'Wed', tr: 'Çar');
  static String get dayThuShort => _t(en: 'Thu', tr: 'Per');
  static String get dayFriShort => _t(en: 'Fri', tr: 'Cum');
  static String get daySatShort => _t(en: 'Sat', tr: 'Cmt');
  static String get daySunShort => _t(en: 'Sun', tr: 'Paz');
  // --- End Nearby Markets Feature ---

  // --- Start Friend Network Feature (Step 1: Profile) ---
  static String get friendNetworkTitle =>
      _t(en: 'Friend Network', tr: 'Arkadaş Ağı');
  static String get friendNetworkHubSubtitle => _t(
      en: 'Connect with people near you',
      tr: 'Yakınınızdaki insanlarla bağlantı kurun');
  static String get myFriendsTitle => _t(en: 'My Friends', tr: 'Arkadaşlarım');
  static String get nearbyPeopleTitle =>
      _t(en: 'Nearby People', tr: 'Yakındaki Kişiler');
  static String get setupProfilePrompt => _t(
      en: 'Set up your Friend Network profile to get started.',
      tr: 'Başlamak için Arkadaş Ağı profilinizi oluşturun.');
  static String get setupProfileButton =>
      _t(en: 'Set Up Profile', tr: 'Profil Oluştur');
  static String get editProfileFriendNetworkButton =>
      _t(en: 'Edit Profile', tr: 'Profili Düzenle');
  static String get chooseAvatarLabel =>
      _t(en: 'Choose an Avatar', tr: 'Bir Avatar Seçin');
  static String get bioLabel => _t(en: 'About You', tr: 'Hakkınızda');
  static String get bioHint => _t(
      en: 'Tell others a little about yourself...',
      tr: 'Kendiniz hakkında biraz bilgi verin...');
  static String get ageRangeLabel => _t(en: 'Age Range', tr: 'Yaş Aralığı');
  static String get genderLabel =>
      _t(en: 'Gender (optional)', tr: 'Cinsiyet (isteğe bağlı)');
  static String get interestsLabel =>
      _t(en: 'Your Interests', tr: 'İlgi Alanlarınız');
  static String get interestsHint =>
      _t(en: 'Select as many as you like', tr: 'İstediğiniz kadar seçin');
  static String get languagesLabel =>
      _t(en: 'Languages You Speak', tr: 'Konuştuğunuz Diller');
  static String get discoverableLabel => _t(
      en: 'Show my profile to nearby people',
      tr: 'Profilimi yakındaki kişilere göster');
  static String get discoverableDescription => _t(
      en: 'When on, other nearby users can find you and send a friend request. Your exact location is never shown — only a general area.',
      tr: 'Açık olduğunda, yakındaki diğer kullanıcılar sizi bulup arkadaşlık isteği gönderebilir. Tam konumunuz asla gösterilmez — yalnızca genel bir bölge gösterilir.');
  static String get genderMale => _t(en: 'Male', tr: 'Erkek');
  static String get genderFemale => _t(en: 'Female', tr: 'Kadın');
  static String get genderPreferNotToSay =>
      _t(en: 'Prefer not to say', tr: 'Belirtmek istemiyorum');
  static String get saveProfileButton =>
      _t(en: 'Save Profile', tr: 'Profili Kaydet');
  static String get profileSavedMessage =>
      _t(en: 'Your profile has been saved.', tr: 'Profiliniz kaydedildi.');
  static String get profileSaveErrorMessage => _t(
      en: 'Could not save your profile. Please check your connection and try again.',
      tr: 'Profiliniz kaydedilemedi. Lütfen bağlantınızı kontrol edip tekrar deneyin.');
  // Age ranges are the same numeric text in both languages.
  static const String ageRange50s = '50-59';
  static const String ageRange60s = '60-69';
  static const String ageRange70s = '70-79';
  static const String ageRange80s = '80-89';
  static const String ageRange90Plus = '90+';
  static String get interestWalking => _t(en: 'Walking', tr: 'Yürüyüş');
  static String get interestGardening => _t(en: 'Gardening', tr: 'Bahçecilik');
  static String get interestReading => _t(en: 'Reading', tr: 'Okumak');
  static String get interestCooking => _t(en: 'Cooking', tr: 'Yemek Yapmak');
  static String get interestPainting => _t(en: 'Painting', tr: 'Resim Yapmak');
  static String get interestCrochet => _t(en: 'Crochet', tr: 'Tığ İşi');
  static String get interestMusic => _t(en: 'Music', tr: 'Müzik');
  static String get interestExercise => _t(en: 'Exercise', tr: 'Egzersiz');
  static String get interestChess => _t(en: 'Chess', tr: 'Satranç');
  static String get interestVolunteering =>
      _t(en: 'Volunteering', tr: 'Gönüllülük');
  static String get languageTurkish => _t(en: 'Turkish', tr: 'Türkçe');
  static String get languageEnglish => _t(en: 'English', tr: 'İngilizce');
  static String get languageOther => _t(en: 'Other', tr: 'Diğer');
  static String get comingInNextStepLabel =>
      _t(en: 'Coming in the next update', tr: 'Sonraki güncellemede geliyor');
  // --- End Friend Network Feature (Step 1: Profile) ---

  // --- Start Friend Network Feature (Step 2: Friends, Discovery, Safety) ---
  static String get friendRequestsTitle =>
      _t(en: 'Friend Requests', tr: 'Arkadaşlık İstekleri');
  static String get acceptButton => _t(en: 'Accept', tr: 'Kabul Et');
  static String get declineButton => _t(en: 'Decline', tr: 'Reddet');
  static String get addButton => _t(en: 'Add', tr: 'Ekle');
  static String get requestedButton =>
      _t(en: 'Requested', tr: 'İstek Gönderildi');
  static String get removeFriendButton =>
      _t(en: 'Remove Friend', tr: 'Arkadaşlıktan Çıkar');
  static String get blockUserButton =>
      _t(en: 'Block User', tr: 'Kullanıcıyı Engelle');
  static String get reportUserButton =>
      _t(en: 'Report User', tr: 'Kullanıcıyı Bildir');
  static String get cancelButton => _t(en: 'Cancel', tr: 'İptal');
  static String get trustedContactLabel =>
      _t(en: 'Trusted Contact', tr: 'Güvenilir Kişi');
  static String get markAsTrustedContact =>
      _t(en: 'Mark as Trusted Contact', tr: 'Güvenilir Kişi Olarak İşaretle');
  static String get unmarkTrustedContact =>
      _t(en: 'Remove Trusted Contact', tr: 'Güvenilir Kişiyi Kaldır');
  static String get moreOptionsLabel =>
      _t(en: 'More Options', tr: 'Diğer Seçenekler');
  static String get confirmRemoveFriendMessage => _t(
      en: 'Remove this person from your friends?',
      tr: 'Bu kişiyi arkadaş listenizden çıkarmak istiyor musunuz?');
  static String get confirmBlockUserMessage => _t(
      en: 'Block this person? They will no longer be able to contact you or appear in your nearby people list.',
      tr: 'Bu kişiyi engellemek istiyor musunuz? Artık sizinle iletişime geçemez veya yakındaki kişiler listenizde görünmez.');
  static String get reportReasonInappropriate =>
      _t(en: 'Inappropriate Behavior', tr: 'Uygunsuz Davranış');
  static String get reportReasonFakeProfile =>
      _t(en: 'Fake Profile', tr: 'Sahte Profil');
  static String get reportReasonSpam =>
      _t(en: 'Spam or Scam', tr: 'Spam veya Dolandırıcılık');
  static String get reportReasonOther => _t(en: 'Other', tr: 'Diğer');
  static String get reportSubmittedMessage => _t(
      en: 'Thank you. Your report has been submitted.',
      tr: 'Teşekkürler. Bildiriminiz gönderildi.');
  static String get noFriendsYetMessage => _t(
      en: "You haven't added any friends yet.",
      tr: 'Henüz arkadaş eklemediniz.');
  static String get noNearbyPeopleMessage => _t(
      en: 'No nearby people found right now.',
      tr: 'Şu anda yakında kimse bulunamadı.');
  static String get friendNetworkGenericError => _t(
      en: 'Something went wrong. Please try again.',
      tr: 'Bir sorun oluştu. Lütfen tekrar deneyin.');
  static String get friendRequestSentMessage =>
      _t(en: 'Friend request sent.', tr: 'Arkadaşlık isteği gönderildi.');
  static String get distanceVeryClose => _t(en: 'Very close', tr: 'Çok yakın');
  static String get distanceNearby => _t(en: 'Nearby', tr: 'Yakında');
  static String get distanceInIzmir => _t(en: 'In İzmir', tr: "İzmir'de");
  static String get distanceFurtherAway =>
      _t(en: 'Further away', tr: 'Daha uzakta');
  static String get distanceUnknown =>
      _t(en: 'Distance unknown', tr: 'Mesafe bilinmiyor');
  static String get yesConfirmButton => _t(en: 'Yes', tr: 'Evet');
  static String get noCancelButton => _t(en: 'No', tr: 'Hayır');
  static String get sinceFriendsLabel =>
      _t(en: 'Friends since', tr: 'Arkadaşlık tarihi');
  static String get discoverabilityOffNotice => _t(
      en: 'Turn on "Show my profile to nearby people" in your profile to discover people near you.',
      tr: 'Yakınınızdaki kişileri keşfetmek için profilinizde "Profilimi yakındaki kişilere göster" seçeneğini açın.');
  static String get discoverableStatusOn =>
      _t(en: 'Discoverable', tr: 'Görünür');
  static String get discoverableStatusOff =>
      _t(en: 'Not Visible', tr: 'Görünür Değil');
  // --- End Friend Network Feature (Step 2: Friends, Discovery, Safety) ---

  // --- Start Friend Network Feature (Step 3: Messaging) ---
  static String get messageButton => _t(en: 'Message', tr: 'Mesaj');
  static String get quickRepliesLabel =>
      _t(en: 'Quick Replies', tr: 'Hazır Yanıtlar');
  static String get messageInputHint =>
      _t(en: 'Type a message...', tr: 'Bir mesaj yazın...');
  static String get noMessagesYetMessage => _t(
      en: 'No messages yet. Say hello!', tr: 'Henüz mesaj yok. Merhaba deyin!');
  static String get messageSendErrorMessage => _t(
      en: 'Could not send message. Please try again.',
      tr: 'Mesaj gönderilemedi. Lütfen tekrar deneyin.');
  static String get templateHello => _t(en: 'Hello!', tr: 'Merhaba!');
  static String get templateHowAreYou =>
      _t(en: 'How are you?', tr: 'Nasılsınız?');
  static String get templateAreYouAvailable =>
      _t(en: 'Are you available today?', tr: 'Bugün müsait misiniz?');
  static String get templateLetsWalk =>
      _t(en: "Let's walk together", tr: 'Birlikte yürüyüş yapalım');
  static String get templateLetsHaveTea =>
      _t(en: "Let's have tea or coffee", tr: 'Çay ya da kahve içelim');
  static String get templateThankYou =>
      _t(en: 'Thank you!', tr: 'Teşekkür ederim!');
  static String get templateSeeYouSoon =>
      _t(en: 'See you soon', tr: 'Yakında görüşürüz');
  static String get templateRunningLate =>
      _t(en: "I'll be a little late", tr: 'Biraz geç kalacağım');
  // --- End Friend Network Feature (Step 3: Messaging) ---

  // --- Start Home Screen (moved from hardcoded literals) ---
  static String get appBrandName =>
      'HealthCare+'; // brand name, unchanged across languages
  static String get homeWelcomeBack =>
      _t(en: 'Welcome back', tr: 'Tekrar hoş geldiniz');
  static String get homeWelcomeSubtitle => _t(
      en: 'You are doing great. Check your reminders.',
      tr: 'Harika gidiyorsunuz. Hatırlatıcılarınızı kontrol edin.');
  static String get yourHealthHubTitle =>
      _t(en: 'Your Health Hub', tr: 'Sağlık Merkeziniz');
  static String get emergencyPermissionsRequiredMessage => _t(
      en: 'Permissions required for Emergency Alert',
      tr: 'Acil Durum Uyarısı için izinler gerekli');
  static String get emergencyAlertFailedPrefix =>
      _t(en: 'Alert failed: ', tr: 'Uyarı başarısız: ');
  static String get safeAlertSentMessage => _t(
      en: 'Safe alert sent successfully',
      tr: 'Güvenlik uyarısı başarıyla gönderildi');
  static String get safeNowSmsMessage => _t(
      en: 'I AM SAFE NOW. Please disregard the previous emergency alert.',
      tr: 'ARTIK GÜVENDEYİM. Lütfen önceki acil durum uyarısını dikkate almayın.');
  static String get emergencySentTitle =>
      _t(en: 'Emergency Sent!', tr: 'Acil Durum Gönderildi!');
  static String get emergencyMessageSentToContacts => _t(
      en: 'The following message was sent to your contacts:',
      tr: 'Kişilerinize şu mesaj gönderildi:');
  static String get callingPrimaryContactMessage =>
      _t(en: 'Calling primary contact...', tr: 'Birincil kişi aranıyor...');
  static String get okButton => _t(en: 'OK', tr: 'Tamam');
  static String get sosAlertHeaderText =>
      _t(en: '🚨 SOS ALERT', tr: '🚨 SOS UYARISI');
  static String get sendingAlertInPrefix =>
      _t(en: 'Sending alert in ', tr: 'Uyarı gönderiliyor: ');
  static String get alertingContactsMessage => _t(
      en: 'Alerting contacts with your location.',
      tr: 'Kişileriniz konumunuzla birlikte uyarılıyor.');
  static String get cancelAlertButton =>
      _t(en: 'Cancel Alert', tr: 'Uyarıyı İptal Et');
  static String get imSafeNowButton =>
      _t(en: "I'M SAFE NOW", tr: 'ARTIK GÜVENDEYİM');
  static String get medicineRemindersTitle =>
      _t(en: 'Medicine Reminders', tr: 'İlaç Hatırlatıcıları');
  static String get medicineRemindersGridSubtitle =>
      _t(en: 'Set medication schedules', tr: 'İlaç programları belirleyin');
  static String get fitnessGridSubtitle =>
      _t(en: 'Simple fitness routines', tr: 'Basit egzersiz rutinleri');
  static String get healthGridSubtitle =>
      _t(en: 'Track your health data', tr: 'Sağlık verilerinizi takip edin');
  // Note: fixed a typo in the original English ("Be Hyderated")
  static String get waterGridSubtitle =>
      _t(en: 'Stay Hydrated', tr: 'Susuz Kalmayın');
  static String get brainGamesGridSubtitle =>
      _t(en: 'Keep your mind sharp', tr: 'Zihninizi keskin tutun');
  // Note: fixed a typo in the original English ("Ask your quries")
  static String get chatbotGridSubtitle =>
      _t(en: 'Ask your queries', tr: 'Sorularınızı sorun');
  // --- End Home Screen ---

  // --- Start Emergency Contacts screen (moved from hardcoded literals) ---
  static String get addContactFabLabel =>
      _t(en: 'Add Contact', tr: 'Kişi Ekle');
  static String get errorPrefix => _t(en: 'Error: ', tr: 'Hata: ');
  static String get deleteContactConfirmTitle =>
      _t(en: 'Delete Contact?', tr: 'Kişi Silinsin mi?');
  static String get confirmDeleteContactPrefix => _t(
      en: 'Are you sure you want to delete ',
      tr: 'Şu kişiyi silmek istediğinizden emin misiniz: ');
  static String get contactNoPhoneNumberMessage => _t(
      en: 'Selected contact has no phone number.',
      tr: 'Seçilen kişinin telefon numarası yok.');
  static String get contactPermissionDeniedMessage => _t(
      en: 'Permission denied. Please allow contact access.',
      tr: 'İzin reddedildi. Lütfen kişilere erişime izin verin.');
  static String get importFromContactsButton => _t(
      en: 'Import from Phone Contacts', tr: 'Telefon Kişilerinden İçe Aktar');
  static String get orDivider => _t(en: 'OR', tr: 'VEYA');
  static String get contactNameRequiredValidation =>
      _t(en: 'Contact name is required', tr: 'Kişi adı gereklidir');
  static String get phoneNumberRequiredValidation =>
      _t(en: 'Phone number is required', tr: 'Telefon numarası gereklidir');
  static String get phoneNumberInvalidValidation => _t(
      en: 'Enter a valid number (digits only)',
      tr: 'Geçerli bir numara girin (yalnızca rakam)');
  // --- End Emergency Contacts screen ---

  // --- Start Reminder Settings Modal (moved from hardcoded literals) ---
  static String get reminderSettingsTitle =>
      _t(en: 'Reminder Settings', tr: 'Hatırlatıcı Ayarları');
  static String get whenToStartLabel =>
      _t(en: 'When to start:', tr: 'Ne zaman başlasın:');
  static String get startNowOption => _t(en: 'Start Now', tr: 'Şimdi Başla');
  static String get startNowDescription => _t(
      en: 'Begin reminders immediately', tr: 'Hatırlatıcılar hemen başlasın');
  static String get customStartTimeOption =>
      _t(en: 'Custom Start Time', tr: 'Özel Başlangıç Saati');
  static String get customStartTimeDescription =>
      _t(en: 'Choose when to begin', tr: 'Ne zaman başlayacağını seçin');
  static String get selectedTimePrefix => _t(en: 'Selected: ', tr: 'Seçilen: ');
  static String get hoursAbbrevShort => _t(en: 'h', tr: 'sa');
  static String get remindersActiveHoursNote => _t(
      en: 'Reminders will only work between these hours',
      tr: 'Hatırlatıcılar yalnızca bu saatler arasında çalışır');
  static String get startHourPrefix =>
      _t(en: 'Start Hour: ', tr: 'Başlangıç Saati: ');
  static String get endHourPrefix => _t(en: 'End Hour: ', tr: 'Bitiş Saati: ');
  static String get startTimeLabel =>
      _t(en: 'Start Time', tr: 'Başlangıç Saati');
  static String get endTimeLabel => _t(en: 'End Time', tr: 'Bitiş Saati');
  static String get soundLabel => _t(en: 'Sound:', tr: 'Ses:');
  static String get soundRingLabel => _t(en: 'Ring', tr: 'Zil');
  static String get soundVoiceLabel => _t(en: 'Voice', tr: 'Sesli');
  static String get startReminderButton =>
      _t(en: 'Start Reminder', tr: 'Hatırlatıcıyı Başlat');
  // --- End Reminder Settings Modal ---
}

// --- Mock Exercise Data with more variety ---
final List<ExerciseModel> exercises = [
  // --- STRETCHING (7 exercises) ---
  ExerciseModel(
    id: 'S1',
    title: 'Gentle Neck Circles',
    description: 'Slow, controlled circles to relax neck and shoulders.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 3),
    difficultyLevel: 1,
    instructions:
        'Slow, controlled circles to relax neck and shoulders. Start slowly, clockwise then counter-clockwise. Do not rush or force movement.',
    imageUrl: 'assets/images/neck_circles.png',
  ),
  ExerciseModel(
    id: 'S2',
    title: 'Shoulder Rolls',
    description: 'Roll shoulders backward and forward to release tension.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 2),
    difficultyLevel: 1,
    instructions:
        'Inhale as you lift shoulders, exhale as you relax them down. 10 reps each direction.',
    imageUrl: 'assets/images/shoulder_roll.png',
  ),
  ExerciseModel(
    id: 'S3',
    title: 'Seated Torso Twist',
    description:
        'Gentle twist to improve spinal mobility. Use a chair for support.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 4),
    difficultyLevel: 2,
    instructions:
        'Sit up straight, gently twist to the left, holding for 30 seconds. Repeat right.',
    imageUrl: 'assets/images/seated_torso_twisted.jpg',
  ),
  ExerciseModel(
    id: 'S4',
    title: 'Wrist and Finger Stretch',
    description: 'Stretching for hands and wrists to maintain dexterity.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 2),
    difficultyLevel: 1,
    instructions:
        'Extend arms, gently pull fingers back towards body. Hold for 15 seconds.',
    imageUrl: 'assets/images/wrist_finger_stretches.jpg',
  ),
  ExerciseModel(
    id: 'S5',
    title: 'Ankle Rotations',
    description: 'Improves ankle flexibility and circulation.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 3),
    difficultyLevel: 1,
    instructions:
        'Sit comfortably. Rotate each ankle clockwise and counterclockwise 15 times. Switch ankles and repeat the same steps.',
    imageUrl: 'assets/images/ankle_rotation.png',
  ),
  ExerciseModel(
    id: 'S6',
    title: 'Standing Quad Stretch (Assisted)',
    description: 'Stretching the front of the thighs with chair assistance.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 5),
    difficultyLevel: 3,
    instructions:
        'Hold a chair. Bend one knee and gently pull heel toward glutes. Hold 20 seconds per side.',
    imageUrl: 'assets/images/standing_quads.png',
  ),
  ExerciseModel(
    id: 'S7',
    title: 'Seated Hamstring Stretch',
    description: 'Reaches the back of the legs while seated.',
    category: ExerciseCategory.stretching,
    duration: const Duration(minutes: 4),
    difficultyLevel: 2,
    instructions:
        'Sit on the edge of a chair, one leg extended. Lean forward slightly from the hips until a stretch is felt.',
    imageUrl: 'assets/images/seated_hamstring.png',
  ),

  // --- STRENGTH (7 exercises) ---
  ExerciseModel(
    id: 'T1',
    title: 'Chair Squats',
    description:
        'Sitting down and standing up without using hands for leg strength.',
    category: ExerciseCategory.strength,
    duration: const Duration(minutes: 5),
    difficultyLevel: 2,
    instructions:
        'Start seated. Lean forward slightly and push through your feet to stand up. Slowly return to the chair. Repeat 10 times.',
    imageUrl: 'assets/images/chair_squats.png',
  ),
  ExerciseModel(
    id: 'T2',
    title: 'Wall Push-ups',
    description: 'Upper body and chest strengthening using a wall.',
    category: ExerciseCategory.strength,
    duration: const Duration(minutes: 4),
    difficultyLevel: 2,
    instructions:
        'Stand facing a wall, hands slightly wider than shoulders. Slowly bend elbows to lower chest toward wall, then push back. 12 repetitions.',
    imageUrl: 'assets/images/wall_push_ups.png',
  ),
  ExerciseModel(
    id: 'T3',
    title: 'Bicep Curls (with light weights)',
    description: 'Building arm and grip strength.',
    category: ExerciseCategory.strength,
    duration: const Duration(minutes: 6),
    difficultyLevel: 3,
    instructions:
        'Use light dumbbells or water bottles. Keep elbows close to sides. Curl slowly up and down. 3 sets of 10.',
    imageUrl: 'assets/images/bicep_curls.png',
  ),
  ExerciseModel(
    id: 'T4',
    title: 'Standing Leg Lifts (Side)',
    description: 'Strengthening hip abductors for better balance.',
    category: ExerciseCategory.strength,
    duration: const Duration(minutes: 4),
    difficultyLevel: 2,
    instructions:
        'Hold a sturdy chair. Keep leg straight and lift it out to the side slowly. Lower slowly. 15 reps per leg.',
    imageUrl: 'assets/images/standing_leg_lifts.png',
  ),
  ExerciseModel(
    id: 'T5',
    title: 'Calf Raises (Assisted)',
    description: 'Strengthening calf muscles to aid walking.',
    category: ExerciseCategory.strength,
    duration: const Duration(minutes: 3),
    difficultyLevel: 1,
    instructions:
        'Hold onto a stable surface. Slowly lift heels, rising onto the balls of your feet. Lower slowly. 20 repetitions.',
    imageUrl: 'assets/images/assisted_calf_raise.png',
  ),
  ExerciseModel(
    id: 'T6',
    title: 'Plank (Modified, on Knees)',
    description: 'Core stabilization and strength.',
    category: ExerciseCategory.strength,
    duration: const Duration(minutes: 3),
    difficultyLevel: 4,
    instructions:
        'Start on hands and knees, then move to forearms. Keep back straight and engage core. Hold for 30 seconds.',
    imageUrl: 'assets/images/plank_exercise.png',
  ),
  ExerciseModel(
    id: 'T7',
    title: 'Triceps Extension (Seated)',
    description: 'Toning and strengthening the back of the arms.',
    category: ExerciseCategory.strength,
    duration: const Duration(minutes: 5),
    difficultyLevel: 3,
    instructions:
        'Use a light weight. Raise arm overhead, then bend elbow to lower weight behind head. Extend back up. 2 sets of 10 per arm.',
    imageUrl: 'assets/images/triceps_extension.png',
  ),

  // --- CARDIO (6 exercises) ---
  ExerciseModel(
    id: 'C1',
    title: 'Marching in Place',
    description: 'Low-impact cardiovascular exercise.',
    category: ExerciseCategory.cardio,
    duration: const Duration(minutes: 10),
    difficultyLevel: 1,
    instructions:
        'Stand tall near a chair or wall for support. Slowly lift one knee toward hip height (or comfortable height). Lower the leg gently and switch sides. Swing arms naturally to improve balance and coordination. Maintain a slow, steady rhythm. Repetitions: 20-40 steps total or 1-2 minutes.',
    imageUrl: 'assets/images/marching.png',
  ),
  ExerciseModel(
    id: 'C2',
    title: 'Seated Punching',
    description: 'Engages core and upper body for a quick cardio burst.',
    category: ExerciseCategory.cardio,
    duration: const Duration(minutes: 5),
    difficultyLevel: 2,
    instructions:
        'Sit upright. Alternate punching arms straight out in front of you. Keep punches light and fast.',
    imageUrl: 'assets/images/seated_punching.png',
  ),
  ExerciseModel(
    id: 'C3',
    title: 'Stepping Side-to-Side',
    description: 'Lateral movement to improve agility and heart rate.',
    category: ExerciseCategory.cardio,
    duration: const Duration(minutes: 8),
    difficultyLevel: 2,
    instructions:
        'Take a step to the right, bring the left foot to meet it. Repeat left. Keep moving briskly.',
    imageUrl: 'assets/images/stepping_side_to_side.png',
  ),
  ExerciseModel(
    id: 'C4',
    title: 'Low-Impact Jumping Jacks (Step Jacks)',
    description: 'Modified full-body cardio with no jumping.',
    category: ExerciseCategory.cardio,
    duration: const Duration(minutes: 7),
    difficultyLevel: 3,
    instructions:
        'Tap on leg sideways away from your body. At the same time as doing this, sweep both your arms in a circular motion to above your head. Bring your arms down at the same time as your leg comes in and repeat with the other leg.',
    imageUrl: 'assets/images/jumping_jack.png',
  ),
  ExerciseModel(
    id: 'C5',
    title: 'Stair Climbing',
    description: 'Excellent lower-body cardio and strength builder.',
    category: ExerciseCategory.cardio,
    duration: const Duration(minutes: 15),
    difficultyLevel: 4,
    instructions:
        'Use a handrail for safety. Step up and down one step repeatedly. Take breaks as needed.',
    imageUrl: 'assets/images/stair_climbing.png',
  ),
  ExerciseModel(
    id: 'C6',
    title: 'Heel Digs',
    description: 'A low-impact alternative to running or marching.',
    category: ExerciseCategory.cardio,
    duration: const Duration(minutes: 6),
    difficultyLevel: 1,
    instructions:
        'Alternate tapping your heels out in front of you while swinging your arms. Maintain a steady pace.',
    imageUrl: 'assets/images/heel_dig.png',
  ),
];
