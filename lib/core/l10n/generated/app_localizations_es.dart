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
  String get help_title => 'Pedir ayuda';

  @override
  String get help_fab_label => 'Pedir ayuda';

  @override
  String help_contact_trustedPerson(String name) {
    return 'Llamar a $name';
  }

  @override
  String get help_contact_bankAdvisor => 'Hablar con el banco';

  @override
  String get help_channel_call => 'Llamar';

  @override
  String get help_channel_chat => 'Escribir';

  @override
  String get help_channel_video =>
      'Videollamada con intérprete de lengua de señas';

  @override
  String help_connecting_trustedPerson(String name) {
    return 'Te estamos conectando con $name...';
  }

  @override
  String get help_connecting_bankAdvisor =>
      'Te estamos conectando con un asesor...';

  @override
  String get help_connecting_videoInterpreter =>
      'Te estamos conectando con un asesor e intérprete de lengua de señas';

  @override
  String help_context_screen(String screen) {
    return 'Está en: $screen';
  }

  @override
  String help_context_operation(String operation, String amount) {
    return 'Operación: $operation por S/ $amount';
  }

  @override
  String get help_context_noOperation => 'Sin operación en curso';

  @override
  String help_context_minimalMessage(String userName) {
    return '$userName necesita ayuda';
  }

  @override
  String help_fallback_title(String name) {
    return 'No pudimos comunicarte con $name';
  }

  @override
  String get help_fallback_question =>
      '¿Quieres hablar con un asesor del banco?';

  @override
  String get help_fallback_yes => 'Sí';

  @override
  String get help_fallback_back => 'Volver';

  @override
  String get help_connected_title => 'Conectado';

  @override
  String help_connected_contextSent(String name) {
    return 'Contexto enviado a $name:';
  }

  @override
  String get help_back_button => 'Volver a la app';

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

  @override
  String get assistant_title => 'Asistente';

  @override
  String get assistant_mic_label => 'Activar micrófono';

  @override
  String get assistant_text_label => 'Escribe tu solicitud';

  @override
  String get assistant_listening => 'Te escucho...';

  @override
  String get assistant_processing => 'Entendiendo...';

  @override
  String get assistant_unknown =>
      'No estoy seguro. ¿Quieres ver tu saldo, pagar un recibo, enviar dinero o pedir ayuda?';

  @override
  String get assistant_outOfScope =>
      'Solo puedo ayudarte con tu cuenta. ¿Quieres ver tu saldo, pagar un recibo, enviar dinero o pedir ayuda?';

  @override
  String assistant_balance(String amount) {
    return 'Tienes S/ $amount disponibles';
  }

  @override
  String assistant_payConfirm(String service, String amount) {
    return 'Vas a pagar tu recibo de $service por S/ $amount. ¿Confirmas con tu huella?';
  }

  @override
  String assistant_sendConfirm(String amount, String name) {
    return 'Vas a enviar S/ $amount a $name. ¿Confirmas con tu huella?';
  }

  @override
  String get assistant_payDone => 'Pago realizado';

  @override
  String get assistant_sendDone => 'Dinero enviado';

  @override
  String get assistant_needsService => '¿Qué recibo quieres pagar?';

  @override
  String get assistant_needsContact => '¿A quién quieres enviarle?';

  @override
  String assistant_needsAmount(String name) {
    return '¿Cuánto quieres enviarle a $name?';
  }

  @override
  String assistant_billNotFound(String service) {
    return 'No encontré un recibo de $service pendiente';
  }

  @override
  String get assistant_speechFailed =>
      'No te escuché bien. ¿Puedes repetir o escribirlo?';

  @override
  String get assistant_biometricReason => 'Confirma la operación';

  @override
  String get assistant_biometricFailed =>
      'No reconocí tu huella. Intenta de nuevo.';

  @override
  String get assistant_confirmButton => 'Confirmar con huella';

  @override
  String get assistant_cancelButton => 'Cancelar';

  @override
  String get assistant_onlyContacts =>
      'Solo puedo enviar a tus contactos guardados. ¿A quién quieres enviarle?';

  @override
  String get assistant_helpRedirect => 'Te conecto con ayuda';

  @override
  String get microphoneConsent_title => 'Permiso para escucharte';

  @override
  String get microphoneConsent_body =>
      'Para entender lo que dices, necesito usar tu micrófono. Solo lo uso mientras hablas, no grabo nada.';

  @override
  String get microphoneConsent_accept => 'Aceptar';

  @override
  String get microphoneConsent_decline => 'No, prefiero escribir';

  @override
  String get microphoneConsent_denied =>
      'Puedes escribirme si prefieres no usar el micrófono.';

  @override
  String get announceHomeScreen => 'Pantalla principal';

  @override
  String announceBalance(String amount) {
    return 'Tu saldo es $amount';
  }

  @override
  String announcePaymentSuccess(String amount, String service) {
    return 'Pago realizado. Pagaste $amount al recibo de $service';
  }

  @override
  String announceTransferSuccess(String amount, String name) {
    return 'Dinero enviado. Enviaste $amount a $name';
  }

  @override
  String announceFraudAlert(String riskMessage) {
    return 'Alerta de seguridad. $riskMessage';
  }

  @override
  String announceHelpConnecting(String name) {
    return 'Te estamos conectando con $name';
  }

  @override
  String announceError(String errorMessage) {
    return '$errorMessage';
  }

  @override
  String get a11y_operationSuccess => 'Operación exitosa';

  @override
  String get trustedPerson_title => 'Mi persona de confianza';

  @override
  String get trustedPerson_explanation =>
      'Tu persona de confianza puede ayudarte, pero no puede tocar tu dinero';

  @override
  String get trustedPerson_register => 'Registrar';

  @override
  String get trustedPerson_nameLabel => 'Nombre';

  @override
  String get trustedPerson_phoneLabel => 'Teléfono';

  @override
  String get trustedPerson_relationshipLabel => 'Relación';

  @override
  String get trustedPerson_permission_securityAlerts => 'Avisos de seguridad';

  @override
  String get trustedPerson_permission_securityAlerts_desc =>
      'Recibe un aviso si la app detecta algo raro';

  @override
  String get trustedPerson_permission_helpRequests => 'Pedidos de ayuda';

  @override
  String get trustedPerson_permission_helpRequests_desc =>
      'Cuando pidas ayuda puedes elegir a esta persona';

  @override
  String get trustedPerson_permission_configHelp => 'Ayudar a configurar';

  @override
  String get trustedPerson_permission_configHelp_desc =>
      'Puede sugerirte cambios pero tú decides';

  @override
  String get trustedPerson_confirmRegister => 'Confirmar';

  @override
  String get trustedPerson_next => 'Siguiente';

  @override
  String get trustedPerson_change => 'Cambiar persona de confianza';

  @override
  String trustedPerson_change_warning(String name) {
    return 'Vas a quitar a $name y registrar a otra persona';
  }

  @override
  String get trustedPerson_remove => 'Quitar persona de confianza';

  @override
  String trustedPerson_remove_warning(String name) {
    return '$name dejará de recibir avisos y no podrá ayudarte';
  }

  @override
  String get trustedPerson_removed => 'Persona de confianza eliminada';

  @override
  String get trustedPerson_registered => 'Persona de confianza registrada';

  @override
  String get trustedPerson_phoneSelf => 'No puedes registrarte a ti mismo';

  @override
  String get trustedPerson_phoneInvalid =>
      'Ingresa 9 dígitos que empiecen con 9';

  @override
  String get trustedPerson_nameRequired => 'Ingresa un nombre';

  @override
  String get trustedPerson_relationshipRequired => 'Ingresa la relación';

  @override
  String get trustedPerson_noPermissions => 'Sin permisos activos';

  @override
  String get trustedPerson_viewPermissions => 'Ver permisos';

  @override
  String get trustedPerson_cancel => 'Cancelar';

  @override
  String get trustedPerson_continue => 'Continuar';

  @override
  String trustedPerson_suggestion_title(String name) {
    return '$name te sugiere';
  }

  @override
  String get trustedPerson_suggestion_accept => 'Aceptar';

  @override
  String get trustedPerson_suggestion_reject => 'No, gracias';

  @override
  String get trustedPerson_suggestion_accepted => 'Cambio aplicado';

  @override
  String get trustedPerson_suggestion_fontSize => 'Hacer la letra más grande';

  @override
  String trustedPerson_suggestion_pending(String name) {
    return 'Tienes una sugerencia de $name';
  }

  @override
  String get trustedPerson_permissionOn => 'Activado';

  @override
  String get trustedPerson_permissionOff => 'Desactivado';

  @override
  String trustedPerson_activePermissions(int count) {
    return '$count permisos activos';
  }

  @override
  String get unlock_proposal_title => 'Tienes una sugerencia';

  @override
  String get unlock_accept => 'Sí, actívalo';

  @override
  String get unlock_practice => 'Primero quiero practicarlo';

  @override
  String get unlock_reject => 'No, por ahora no';

  @override
  String get unlock_feature_transactions => 'Ver movimientos';

  @override
  String get unlock_feature_recharge => 'Recargar celular';

  @override
  String get unlock_feature_qr => 'Pagar con QR';

  @override
  String get unlock_proposal_transactions =>
      'Ya manejas bien tus pagos. ¿Quieres ver tus movimientos?';

  @override
  String get unlock_proposal_recharge =>
      '¿Quieres recargar tu celular desde la app?';

  @override
  String get unlock_proposal_qr => '¿Quieres pagar con código QR?';

  @override
  String get unlock_moreFeatures => 'Más funciones';

  @override
  String get unlock_resetToBasic => 'Volver a solo 4 acciones';

  @override
  String get unlock_resetConfirm =>
      'Vas a ocultar las funciones extra. Puedes volver a activarlas cuando quieras.';

  @override
  String get unlock_reactivate => 'Activar de nuevo';

  @override
  String get unlock_desc_transactions => 'Consulta tus últimos movimientos';

  @override
  String get unlock_desc_recharge => 'Recarga tu celular con un monto fijo';

  @override
  String get unlock_desc_qr => 'Escanea un código y paga';

  @override
  String announceUnlockProposal(String message) {
    return 'Sugerencia. $message';
  }

  @override
  String get friction_offerMessage =>
      'Parece que necesitas ayuda con este paso';

  @override
  String get friction_offerMessageField =>
      'Parece que hay un problema con este campo. ¿Te ayudo?';

  @override
  String get friction_offerMessageInactivity =>
      '¿Necesitas ayuda con este paso?';

  @override
  String get friction_optionExplain => 'Sí, explícame';

  @override
  String get friction_optionHuman => 'Hablar con alguien';

  @override
  String get friction_optionDismiss => 'No, estoy bien';

  @override
  String get friction_explain_payBillConfirm =>
      'El botón confirmar envía el pago. Tu dinero está seguro';

  @override
  String get friction_explain_sendMoneyAmount =>
      'Escribe cuánto dinero quieres enviar. Por ejemplo, 50';

  @override
  String get friction_explain_sendMoneyConfirm =>
      'Confirma que los datos son correctos y envía el dinero';

  @override
  String get friction_explain_payBillSelect =>
      'Elige el recibo que quieres pagar de la lista';

  @override
  String friction_contextBack(int n, String stepName) {
    return 'Retrocedió $n veces en $stepName';
  }

  @override
  String friction_contextInactivity(String stepName) {
    return 'Estuvo sin interactuar en $stepName';
  }

  @override
  String friction_contextError(int n, String stepName) {
    return 'Cometió el mismo error $n veces en $stepName';
  }
}
