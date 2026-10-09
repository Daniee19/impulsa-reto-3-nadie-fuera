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

  /// No description provided for @help_title.
  ///
  /// In es, this message translates to:
  /// **'Pedir ayuda'**
  String get help_title;

  /// No description provided for @help_fab_label.
  ///
  /// In es, this message translates to:
  /// **'Pedir ayuda'**
  String get help_fab_label;

  /// No description provided for @help_contact_trustedPerson.
  ///
  /// In es, this message translates to:
  /// **'Llamar a {name}'**
  String help_contact_trustedPerson(String name);

  /// No description provided for @help_contact_bankAdvisor.
  ///
  /// In es, this message translates to:
  /// **'Hablar con el banco'**
  String get help_contact_bankAdvisor;

  /// No description provided for @help_channel_call.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get help_channel_call;

  /// No description provided for @help_channel_chat.
  ///
  /// In es, this message translates to:
  /// **'Escribir'**
  String get help_channel_chat;

  /// No description provided for @help_channel_video.
  ///
  /// In es, this message translates to:
  /// **'Videollamada con intérprete de lengua de señas'**
  String get help_channel_video;

  /// No description provided for @help_connecting_trustedPerson.
  ///
  /// In es, this message translates to:
  /// **'Te estamos conectando con {name}...'**
  String help_connecting_trustedPerson(String name);

  /// No description provided for @help_connecting_bankAdvisor.
  ///
  /// In es, this message translates to:
  /// **'Te estamos conectando con un asesor...'**
  String get help_connecting_bankAdvisor;

  /// No description provided for @help_connecting_videoInterpreter.
  ///
  /// In es, this message translates to:
  /// **'Te estamos conectando con un asesor e intérprete de lengua de señas'**
  String get help_connecting_videoInterpreter;

  /// No description provided for @help_context_screen.
  ///
  /// In es, this message translates to:
  /// **'Está en: {screen}'**
  String help_context_screen(String screen);

  /// No description provided for @help_context_operation.
  ///
  /// In es, this message translates to:
  /// **'Operación: {operation} por S/ {amount}'**
  String help_context_operation(String operation, String amount);

  /// No description provided for @help_context_noOperation.
  ///
  /// In es, this message translates to:
  /// **'Sin operación en curso'**
  String get help_context_noOperation;

  /// No description provided for @help_context_minimalMessage.
  ///
  /// In es, this message translates to:
  /// **'{userName} necesita ayuda'**
  String help_context_minimalMessage(String userName);

  /// No description provided for @help_fallback_title.
  ///
  /// In es, this message translates to:
  /// **'No pudimos comunicarte con {name}'**
  String help_fallback_title(String name);

  /// No description provided for @help_fallback_question.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres hablar con un asesor del banco?'**
  String get help_fallback_question;

  /// No description provided for @help_fallback_yes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get help_fallback_yes;

  /// No description provided for @help_fallback_back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get help_fallback_back;

  /// No description provided for @help_connected_title.
  ///
  /// In es, this message translates to:
  /// **'Conectado'**
  String get help_connected_title;

  /// No description provided for @help_connected_contextSent.
  ///
  /// In es, this message translates to:
  /// **'Contexto enviado a {name}:'**
  String help_connected_contextSent(String name);

  /// No description provided for @help_back_button.
  ///
  /// In es, this message translates to:
  /// **'Volver a la app'**
  String get help_back_button;

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

  /// No description provided for @assistant_title.
  ///
  /// In es, this message translates to:
  /// **'Asistente'**
  String get assistant_title;

  /// No description provided for @assistant_mic_label.
  ///
  /// In es, this message translates to:
  /// **'Activar micrófono'**
  String get assistant_mic_label;

  /// No description provided for @assistant_text_label.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu solicitud'**
  String get assistant_text_label;

  /// No description provided for @assistant_listening.
  ///
  /// In es, this message translates to:
  /// **'Te escucho...'**
  String get assistant_listening;

  /// No description provided for @assistant_processing.
  ///
  /// In es, this message translates to:
  /// **'Entendiendo...'**
  String get assistant_processing;

  /// No description provided for @assistant_unknown.
  ///
  /// In es, this message translates to:
  /// **'No estoy seguro. ¿Quieres ver tu saldo, pagar un recibo, enviar dinero o pedir ayuda?'**
  String get assistant_unknown;

  /// No description provided for @assistant_outOfScope.
  ///
  /// In es, this message translates to:
  /// **'Solo puedo ayudarte con tu cuenta. ¿Quieres ver tu saldo, pagar un recibo, enviar dinero o pedir ayuda?'**
  String get assistant_outOfScope;

  /// No description provided for @assistant_balance.
  ///
  /// In es, this message translates to:
  /// **'Tienes S/ {amount} disponibles'**
  String assistant_balance(String amount);

  /// No description provided for @assistant_payConfirm.
  ///
  /// In es, this message translates to:
  /// **'Vas a pagar tu recibo de {service} por S/ {amount}. ¿Confirmas con tu huella?'**
  String assistant_payConfirm(String service, String amount);

  /// No description provided for @assistant_sendConfirm.
  ///
  /// In es, this message translates to:
  /// **'Vas a enviar S/ {amount} a {name}. ¿Confirmas con tu huella?'**
  String assistant_sendConfirm(String amount, String name);

  /// No description provided for @assistant_payDone.
  ///
  /// In es, this message translates to:
  /// **'Pago realizado'**
  String get assistant_payDone;

  /// No description provided for @assistant_sendDone.
  ///
  /// In es, this message translates to:
  /// **'Dinero enviado'**
  String get assistant_sendDone;

  /// No description provided for @assistant_needsService.
  ///
  /// In es, this message translates to:
  /// **'¿Qué recibo quieres pagar?'**
  String get assistant_needsService;

  /// No description provided for @assistant_needsContact.
  ///
  /// In es, this message translates to:
  /// **'¿A quién quieres enviarle?'**
  String get assistant_needsContact;

  /// No description provided for @assistant_needsAmount.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto quieres enviarle a {name}?'**
  String assistant_needsAmount(String name);

  /// No description provided for @assistant_billNotFound.
  ///
  /// In es, this message translates to:
  /// **'No encontré un recibo de {service} pendiente'**
  String assistant_billNotFound(String service);

  /// No description provided for @assistant_speechFailed.
  ///
  /// In es, this message translates to:
  /// **'No te escuché bien. ¿Puedes repetir o escribirlo?'**
  String get assistant_speechFailed;

  /// No description provided for @assistant_biometricReason.
  ///
  /// In es, this message translates to:
  /// **'Confirma la operación'**
  String get assistant_biometricReason;

  /// No description provided for @assistant_biometricFailed.
  ///
  /// In es, this message translates to:
  /// **'No reconocí tu huella. Intenta de nuevo.'**
  String get assistant_biometricFailed;

  /// No description provided for @assistant_confirmButton.
  ///
  /// In es, this message translates to:
  /// **'Confirmar con huella'**
  String get assistant_confirmButton;

  /// No description provided for @assistant_cancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get assistant_cancelButton;

  /// No description provided for @assistant_onlyContacts.
  ///
  /// In es, this message translates to:
  /// **'Solo puedo enviar a tus contactos guardados. ¿A quién quieres enviarle?'**
  String get assistant_onlyContacts;

  /// No description provided for @assistant_helpRedirect.
  ///
  /// In es, this message translates to:
  /// **'Te conecto con ayuda'**
  String get assistant_helpRedirect;

  /// No description provided for @microphoneConsent_title.
  ///
  /// In es, this message translates to:
  /// **'Permiso para escucharte'**
  String get microphoneConsent_title;

  /// No description provided for @microphoneConsent_body.
  ///
  /// In es, this message translates to:
  /// **'Para entender lo que dices, necesito usar tu micrófono. Solo lo uso mientras hablas, no grabo nada.'**
  String get microphoneConsent_body;

  /// No description provided for @microphoneConsent_accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get microphoneConsent_accept;

  /// No description provided for @microphoneConsent_decline.
  ///
  /// In es, this message translates to:
  /// **'No, prefiero escribir'**
  String get microphoneConsent_decline;

  /// No description provided for @microphoneConsent_denied.
  ///
  /// In es, this message translates to:
  /// **'Puedes escribirme si prefieres no usar el micrófono.'**
  String get microphoneConsent_denied;

  /// No description provided for @announceHomeScreen.
  ///
  /// In es, this message translates to:
  /// **'Pantalla principal'**
  String get announceHomeScreen;

  /// No description provided for @announceBalance.
  ///
  /// In es, this message translates to:
  /// **'Tu saldo es {amount}'**
  String announceBalance(String amount);

  /// No description provided for @announcePaymentSuccess.
  ///
  /// In es, this message translates to:
  /// **'Pago realizado. Pagaste {amount} al recibo de {service}'**
  String announcePaymentSuccess(String amount, String service);

  /// No description provided for @announceTransferSuccess.
  ///
  /// In es, this message translates to:
  /// **'Dinero enviado. Enviaste {amount} a {name}'**
  String announceTransferSuccess(String amount, String name);

  /// No description provided for @announceFraudAlert.
  ///
  /// In es, this message translates to:
  /// **'Alerta de seguridad. {riskMessage}'**
  String announceFraudAlert(String riskMessage);

  /// No description provided for @announceHelpConnecting.
  ///
  /// In es, this message translates to:
  /// **'Te estamos conectando con {name}'**
  String announceHelpConnecting(String name);

  /// No description provided for @announceError.
  ///
  /// In es, this message translates to:
  /// **'{errorMessage}'**
  String announceError(String errorMessage);

  /// No description provided for @a11y_operationSuccess.
  ///
  /// In es, this message translates to:
  /// **'Operación exitosa'**
  String get a11y_operationSuccess;

  /// No description provided for @trustedPerson_title.
  ///
  /// In es, this message translates to:
  /// **'Mi persona de confianza'**
  String get trustedPerson_title;

  /// No description provided for @trustedPerson_explanation.
  ///
  /// In es, this message translates to:
  /// **'Tu persona de confianza puede ayudarte, pero no puede tocar tu dinero'**
  String get trustedPerson_explanation;

  /// No description provided for @trustedPerson_register.
  ///
  /// In es, this message translates to:
  /// **'Registrar'**
  String get trustedPerson_register;

  /// No description provided for @trustedPerson_nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get trustedPerson_nameLabel;

  /// No description provided for @trustedPerson_phoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get trustedPerson_phoneLabel;

  /// No description provided for @trustedPerson_relationshipLabel.
  ///
  /// In es, this message translates to:
  /// **'Relación'**
  String get trustedPerson_relationshipLabel;

  /// No description provided for @trustedPerson_permission_securityAlerts.
  ///
  /// In es, this message translates to:
  /// **'Avisos de seguridad'**
  String get trustedPerson_permission_securityAlerts;

  /// No description provided for @trustedPerson_permission_securityAlerts_desc.
  ///
  /// In es, this message translates to:
  /// **'Recibe un aviso si la app detecta algo raro'**
  String get trustedPerson_permission_securityAlerts_desc;

  /// No description provided for @trustedPerson_permission_helpRequests.
  ///
  /// In es, this message translates to:
  /// **'Pedidos de ayuda'**
  String get trustedPerson_permission_helpRequests;

  /// No description provided for @trustedPerson_permission_helpRequests_desc.
  ///
  /// In es, this message translates to:
  /// **'Cuando pidas ayuda puedes elegir a esta persona'**
  String get trustedPerson_permission_helpRequests_desc;

  /// No description provided for @trustedPerson_permission_configHelp.
  ///
  /// In es, this message translates to:
  /// **'Ayudar a configurar'**
  String get trustedPerson_permission_configHelp;

  /// No description provided for @trustedPerson_permission_configHelp_desc.
  ///
  /// In es, this message translates to:
  /// **'Puede sugerirte cambios pero tú decides'**
  String get trustedPerson_permission_configHelp_desc;

  /// No description provided for @trustedPerson_confirmRegister.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get trustedPerson_confirmRegister;

  /// No description provided for @trustedPerson_next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get trustedPerson_next;

  /// No description provided for @trustedPerson_change.
  ///
  /// In es, this message translates to:
  /// **'Cambiar persona de confianza'**
  String get trustedPerson_change;

  /// No description provided for @trustedPerson_change_warning.
  ///
  /// In es, this message translates to:
  /// **'Vas a quitar a {name} y registrar a otra persona'**
  String trustedPerson_change_warning(String name);

  /// No description provided for @trustedPerson_remove.
  ///
  /// In es, this message translates to:
  /// **'Quitar persona de confianza'**
  String get trustedPerson_remove;

  /// No description provided for @trustedPerson_remove_warning.
  ///
  /// In es, this message translates to:
  /// **'{name} dejará de recibir avisos y no podrá ayudarte'**
  String trustedPerson_remove_warning(String name);

  /// No description provided for @trustedPerson_removed.
  ///
  /// In es, this message translates to:
  /// **'Persona de confianza eliminada'**
  String get trustedPerson_removed;

  /// No description provided for @trustedPerson_registered.
  ///
  /// In es, this message translates to:
  /// **'Persona de confianza registrada'**
  String get trustedPerson_registered;

  /// No description provided for @trustedPerson_phoneSelf.
  ///
  /// In es, this message translates to:
  /// **'No puedes registrarte a ti mismo'**
  String get trustedPerson_phoneSelf;

  /// No description provided for @trustedPerson_phoneInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa 9 dígitos que empiecen con 9'**
  String get trustedPerson_phoneInvalid;

  /// No description provided for @trustedPerson_nameRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un nombre'**
  String get trustedPerson_nameRequired;

  /// No description provided for @trustedPerson_relationshipRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la relación'**
  String get trustedPerson_relationshipRequired;

  /// No description provided for @trustedPerson_noPermissions.
  ///
  /// In es, this message translates to:
  /// **'Sin permisos activos'**
  String get trustedPerson_noPermissions;

  /// No description provided for @trustedPerson_viewPermissions.
  ///
  /// In es, this message translates to:
  /// **'Ver permisos'**
  String get trustedPerson_viewPermissions;

  /// No description provided for @trustedPerson_cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get trustedPerson_cancel;

  /// No description provided for @trustedPerson_continue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get trustedPerson_continue;

  /// No description provided for @trustedPerson_suggestion_title.
  ///
  /// In es, this message translates to:
  /// **'{name} te sugiere'**
  String trustedPerson_suggestion_title(String name);

  /// No description provided for @trustedPerson_suggestion_accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get trustedPerson_suggestion_accept;

  /// No description provided for @trustedPerson_suggestion_reject.
  ///
  /// In es, this message translates to:
  /// **'No, gracias'**
  String get trustedPerson_suggestion_reject;

  /// No description provided for @trustedPerson_suggestion_accepted.
  ///
  /// In es, this message translates to:
  /// **'Cambio aplicado'**
  String get trustedPerson_suggestion_accepted;

  /// No description provided for @trustedPerson_suggestion_fontSize.
  ///
  /// In es, this message translates to:
  /// **'Hacer la letra más grande'**
  String get trustedPerson_suggestion_fontSize;

  /// No description provided for @trustedPerson_suggestion_pending.
  ///
  /// In es, this message translates to:
  /// **'Tienes una sugerencia de {name}'**
  String trustedPerson_suggestion_pending(String name);

  /// No description provided for @trustedPerson_permissionOn.
  ///
  /// In es, this message translates to:
  /// **'Activado'**
  String get trustedPerson_permissionOn;

  /// No description provided for @trustedPerson_permissionOff.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get trustedPerson_permissionOff;

  /// No description provided for @trustedPerson_activePermissions.
  ///
  /// In es, this message translates to:
  /// **'{count} permisos activos'**
  String trustedPerson_activePermissions(int count);

  /// No description provided for @unlock_proposal_title.
  ///
  /// In es, this message translates to:
  /// **'Tienes una sugerencia'**
  String get unlock_proposal_title;

  /// No description provided for @unlock_accept.
  ///
  /// In es, this message translates to:
  /// **'Sí, actívalo'**
  String get unlock_accept;

  /// No description provided for @unlock_practice.
  ///
  /// In es, this message translates to:
  /// **'Primero quiero practicarlo'**
  String get unlock_practice;

  /// No description provided for @unlock_reject.
  ///
  /// In es, this message translates to:
  /// **'No, por ahora no'**
  String get unlock_reject;

  /// No description provided for @unlock_feature_transactions.
  ///
  /// In es, this message translates to:
  /// **'Ver movimientos'**
  String get unlock_feature_transactions;

  /// No description provided for @unlock_feature_recharge.
  ///
  /// In es, this message translates to:
  /// **'Recargar celular'**
  String get unlock_feature_recharge;

  /// No description provided for @unlock_feature_qr.
  ///
  /// In es, this message translates to:
  /// **'Pagar con QR'**
  String get unlock_feature_qr;

  /// No description provided for @unlock_proposal_transactions.
  ///
  /// In es, this message translates to:
  /// **'Ya manejas bien tus pagos. ¿Quieres ver tus movimientos?'**
  String get unlock_proposal_transactions;

  /// No description provided for @unlock_proposal_recharge.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres recargar tu celular desde la app?'**
  String get unlock_proposal_recharge;

  /// No description provided for @unlock_proposal_qr.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres pagar con código QR?'**
  String get unlock_proposal_qr;

  /// No description provided for @unlock_moreFeatures.
  ///
  /// In es, this message translates to:
  /// **'Más funciones'**
  String get unlock_moreFeatures;

  /// No description provided for @unlock_resetToBasic.
  ///
  /// In es, this message translates to:
  /// **'Volver a solo 4 acciones'**
  String get unlock_resetToBasic;

  /// No description provided for @unlock_resetConfirm.
  ///
  /// In es, this message translates to:
  /// **'Vas a ocultar las funciones extra. Puedes volver a activarlas cuando quieras.'**
  String get unlock_resetConfirm;

  /// No description provided for @unlock_reactivate.
  ///
  /// In es, this message translates to:
  /// **'Activar de nuevo'**
  String get unlock_reactivate;

  /// No description provided for @unlock_desc_transactions.
  ///
  /// In es, this message translates to:
  /// **'Consulta tus últimos movimientos'**
  String get unlock_desc_transactions;

  /// No description provided for @unlock_desc_recharge.
  ///
  /// In es, this message translates to:
  /// **'Recarga tu celular con un monto fijo'**
  String get unlock_desc_recharge;

  /// No description provided for @unlock_desc_qr.
  ///
  /// In es, this message translates to:
  /// **'Escanea un código y paga'**
  String get unlock_desc_qr;

  /// No description provided for @announceUnlockProposal.
  ///
  /// In es, this message translates to:
  /// **'Sugerencia. {message}'**
  String announceUnlockProposal(String message);
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
