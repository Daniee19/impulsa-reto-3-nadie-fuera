import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @easyMode_home_title.
  ///
  /// In es, this message translates to:
  /// **'Modo Fácil'**
  String get easyMode_home_title;

  /// No description provided for @easyMode_home_checkBalance.
  ///
  /// In es, this message translates to:
  /// **'Ver mi saldo'**
  String get easyMode_home_checkBalance;

  /// No description provided for @easyMode_home_payBill.
  ///
  /// In es, this message translates to:
  /// **'Pagar recibo'**
  String get easyMode_home_payBill;

  /// No description provided for @easyMode_home_sendMoney.
  ///
  /// In es, this message translates to:
  /// **'Enviar dinero'**
  String get easyMode_home_sendMoney;

  /// No description provided for @easyMode_home_getHelp.
  ///
  /// In es, this message translates to:
  /// **'Pedir ayuda'**
  String get easyMode_home_getHelp;

  /// No description provided for @easyMode_balance_title.
  ///
  /// In es, this message translates to:
  /// **'Tu saldo'**
  String get easyMode_balance_title;

  /// No description provided for @easyMode_balance_accountLabel.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get easyMode_balance_accountLabel;

  /// No description provided for @easyMode_balance_availableBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo disponible'**
  String get easyMode_balance_availableBalance;

  /// No description provided for @easyMode_payBill_title.
  ///
  /// In es, this message translates to:
  /// **'Pagar recibo'**
  String get easyMode_payBill_title;

  /// No description provided for @easyMode_payBill_noPending.
  ///
  /// In es, this message translates to:
  /// **'No tienes recibos pendientes'**
  String get easyMode_payBill_noPending;

  /// No description provided for @easyMode_payBill_dueDate.
  ///
  /// In es, this message translates to:
  /// **'Vence el {date}'**
  String easyMode_payBill_dueDate(String date);

  /// No description provided for @easyMode_payBill_confirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar pago'**
  String get easyMode_payBill_confirmTitle;

  /// No description provided for @easyMode_payBill_service.
  ///
  /// In es, this message translates to:
  /// **'Servicio'**
  String get easyMode_payBill_service;

  /// No description provided for @easyMode_payBill_amount.
  ///
  /// In es, this message translates to:
  /// **'Monto a pagar'**
  String get easyMode_payBill_amount;

  /// No description provided for @easyMode_sendMoney_title.
  ///
  /// In es, this message translates to:
  /// **'Enviar dinero'**
  String get easyMode_sendMoney_title;

  /// No description provided for @easyMode_sendMoney_noContacts.
  ///
  /// In es, this message translates to:
  /// **'No tienes contactos guardados. Pide ayuda para agregar uno.'**
  String get easyMode_sendMoney_noContacts;

  /// No description provided for @easyMode_sendMoney_enterAmount.
  ///
  /// In es, this message translates to:
  /// **'Escribe el monto'**
  String get easyMode_sendMoney_enterAmount;

  /// No description provided for @easyMode_sendMoney_confirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar envío'**
  String get easyMode_sendMoney_confirmTitle;

  /// No description provided for @easyMode_sendMoney_recipient.
  ///
  /// In es, this message translates to:
  /// **'Para'**
  String get easyMode_sendMoney_recipient;

  /// No description provided for @easyMode_sendMoney_amountLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto a enviar'**
  String get easyMode_sendMoney_amountLabel;

  /// No description provided for @easyMode_sendMoney_remainingBalance.
  ///
  /// In es, this message translates to:
  /// **'Tu saldo después del envío'**
  String get easyMode_sendMoney_remainingBalance;

  /// No description provided for @easyMode_sendMoney_insufficientFunds.
  ///
  /// In es, this message translates to:
  /// **'No tienes suficiente dinero. Tu saldo es S/ {balance}'**
  String easyMode_sendMoney_insufficientFunds(String balance);

  /// No description provided for @easyMode_help_title.
  ///
  /// In es, this message translates to:
  /// **'Pedir ayuda'**
  String get easyMode_help_title;

  /// No description provided for @easyMode_help_callAdvisor.
  ///
  /// In es, this message translates to:
  /// **'Llamar a un asesor'**
  String get easyMode_help_callAdvisor;

  /// No description provided for @easyMode_help_chatAdvisor.
  ///
  /// In es, this message translates to:
  /// **'Escribir a un asesor'**
  String get easyMode_help_chatAdvisor;

  /// No description provided for @easyMode_help_connecting.
  ///
  /// In es, this message translates to:
  /// **'Te estamos conectando con alguien que te va a ayudar'**
  String get easyMode_help_connecting;

  /// No description provided for @easyMode_confirm_button.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get easyMode_confirm_button;

  /// No description provided for @easyMode_back_button.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get easyMode_back_button;

  /// No description provided for @easyMode_success_paymentDone.
  ///
  /// In es, this message translates to:
  /// **'Pago realizado'**
  String get easyMode_success_paymentDone;

  /// No description provided for @easyMode_success_transferDone.
  ///
  /// In es, this message translates to:
  /// **'Dinero enviado'**
  String get easyMode_success_transferDone;

  /// No description provided for @easyMode_success_goHome.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get easyMode_success_goHome;

  /// No description provided for @easyMode_error_generic.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Tu dinero no se movió.'**
  String get easyMode_error_generic;

  /// No description provided for @easyMode_error_tryAgainOrHelp.
  ///
  /// In es, this message translates to:
  /// **'Puedes intentar de nuevo o pedir ayuda'**
  String get easyMode_error_tryAgainOrHelp;

  /// No description provided for @easyMode_error_amountZero.
  ///
  /// In es, this message translates to:
  /// **'El monto debe ser mayor a cero'**
  String get easyMode_error_amountZero;

  /// No description provided for @easyMode_currency.
  ///
  /// In es, this message translates to:
  /// **'S/ {amount}'**
  String easyMode_currency(String amount);

  /// No description provided for @fraudShield_alert_title.
  ///
  /// In es, this message translates to:
  /// **'Un momento'**
  String get fraudShield_alert_title;

  /// No description provided for @fraudShield_alert_unusualAmount.
  ///
  /// In es, this message translates to:
  /// **'Este pago es mucho más alto de lo que sueles pagar.'**
  String get fraudShield_alert_unusualAmount;

  /// No description provided for @fraudShield_alert_newRecipient.
  ///
  /// In es, this message translates to:
  /// **'Nunca le has enviado dinero a esta persona.'**
  String get fraudShield_alert_newRecipient;

  /// No description provided for @fraudShield_alert_highFrequency.
  ///
  /// In es, this message translates to:
  /// **'Has hecho varios pagos seguidos.'**
  String get fraudShield_alert_highFrequency;

  /// No description provided for @fraudShield_alert_unusualTime.
  ///
  /// In es, this message translates to:
  /// **'Estás haciendo un pago a una hora poco habitual.'**
  String get fraudShield_alert_unusualTime;

  /// No description provided for @fraudShield_alert_closing.
  ///
  /// In es, this message translates to:
  /// **'Solo queremos asegurarnos. ¿Qué quieres hacer?'**
  String get fraudShield_alert_closing;

  /// No description provided for @fraudShield_action_cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get fraudShield_action_cancel;

  /// No description provided for @fraudShield_action_continue.
  ///
  /// In es, this message translates to:
  /// **'Continuar de todos modos'**
  String get fraudShield_action_continue;

  /// No description provided for @fraudShield_action_consultTrusted.
  ///
  /// In es, this message translates to:
  /// **'Consultar a {name}'**
  String fraudShield_action_consultTrusted(String name);

  /// No description provided for @fraudShield_notification_sent.
  ///
  /// In es, this message translates to:
  /// **'Le avisamos a {name}. Puedes esperarle o continuar.'**
  String fraudShield_notification_sent(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
