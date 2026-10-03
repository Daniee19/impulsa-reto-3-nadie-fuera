// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get easyMode_home_title => 'Modo Fácil';

  @override
  String get easyMode_home_checkBalance => 'Ver mi saldo';

  @override
  String get easyMode_home_payBill => 'Pagar recibo';

  @override
  String get easyMode_home_sendMoney => 'Enviar dinero';

  @override
  String get easyMode_home_getHelp => 'Pedir ayuda';

  @override
  String get easyMode_balance_title => 'Tu saldo';

  @override
  String get easyMode_balance_accountLabel => 'Cuenta';

  @override
  String get easyMode_balance_availableBalance => 'Saldo disponible';

  @override
  String get easyMode_payBill_title => 'Pagar recibo';

  @override
  String get easyMode_payBill_noPending => 'No tienes recibos pendientes';

  @override
  String easyMode_payBill_dueDate(String date) {
    return 'Vence el $date';
  }

  @override
  String get easyMode_payBill_confirmTitle => 'Confirmar pago';

  @override
  String get easyMode_payBill_service => 'Servicio';

  @override
  String get easyMode_payBill_amount => 'Monto a pagar';

  @override
  String get easyMode_sendMoney_title => 'Enviar dinero';

  @override
  String get easyMode_sendMoney_noContacts =>
      'No tienes contactos guardados. Pide ayuda para agregar uno.';

  @override
  String get easyMode_sendMoney_enterAmount => 'Escribe el monto';

  @override
  String get easyMode_sendMoney_confirmTitle => 'Confirmar envío';

  @override
  String get easyMode_sendMoney_recipient => 'Para';

  @override
  String get easyMode_sendMoney_amountLabel => 'Monto a enviar';

  @override
  String get easyMode_sendMoney_remainingBalance =>
      'Tu saldo después del envío';

  @override
  String easyMode_sendMoney_insufficientFunds(String balance) {
    return 'No tienes suficiente dinero. Tu saldo es S/ $balance';
  }

  @override
  String get easyMode_help_title => 'Pedir ayuda';

  @override
  String get easyMode_help_callAdvisor => 'Llamar a un asesor';

  @override
  String get easyMode_help_chatAdvisor => 'Escribir a un asesor';

  @override
  String get easyMode_help_connecting =>
      'Te estamos conectando con alguien que te va a ayudar';

  @override
  String get easyMode_confirm_button => 'Confirmar';

  @override
  String get easyMode_back_button => 'Volver';

  @override
  String get easyMode_success_paymentDone => 'Pago realizado';

  @override
  String get easyMode_success_transferDone => 'Dinero enviado';

  @override
  String get easyMode_success_goHome => 'Volver al inicio';

  @override
  String get easyMode_error_generic => 'Algo salió mal. Tu dinero no se movió.';

  @override
  String get easyMode_error_tryAgainOrHelp =>
      'Puedes intentar de nuevo o pedir ayuda';

  @override
  String get easyMode_error_amountZero => 'El monto debe ser mayor a cero';

  @override
  String easyMode_currency(String amount) {
    return 'S/ $amount';
  }

  @override
  String get fraudShield_alert_title => 'Un momento';

  @override
  String get fraudShield_alert_unusualAmount =>
      'Este pago es mucho más alto de lo que sueles pagar.';

  @override
  String get fraudShield_alert_newRecipient =>
      'Nunca le has enviado dinero a esta persona.';

  @override
  String get fraudShield_alert_highFrequency =>
      'Has hecho varios pagos seguidos.';

  @override
  String get fraudShield_alert_unusualTime =>
      'Estás haciendo un pago a una hora poco habitual.';

  @override
  String get fraudShield_alert_closing =>
      'Solo queremos asegurarnos. ¿Qué quieres hacer?';

  @override
  String get fraudShield_action_cancel => 'Cancelar';

  @override
  String get fraudShield_action_continue => 'Continuar de todos modos';

  @override
  String fraudShield_action_consultTrusted(String name) {
    return 'Consultar a $name';
  }

  @override
  String fraudShield_notification_sent(String name) {
    return 'Le avisamos a $name. Puedes esperarle o continuar.';
  }
}
