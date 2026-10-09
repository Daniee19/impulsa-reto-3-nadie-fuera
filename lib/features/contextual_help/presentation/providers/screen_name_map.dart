/// Maps route patterns to human-readable Spanish screen names.
const screenNameMap = <String, String>{
  '/easy-mode': 'Pantalla principal',
  '/easy-mode/balance': 'Ver mi saldo',
  '/easy-mode/pay-bill': 'Elegir recibo para pagar',
  '/easy-mode/send-money': 'Enviar dinero',
  '/easy-mode/send-money/confirm': 'Confirmación de envío',
  '/easy-mode/fraud-alert': 'Alerta de seguridad',
  '/easy-mode/success': 'Operación exitosa',
};

/// Resolves a route path to a Spanish screen name.
String resolveScreenName(String route) {
  final direct = screenNameMap[route];
  if (direct != null) return direct;

  if (route.startsWith('/easy-mode/help')) return 'Pidiendo ayuda';
  if (RegExp('/easy-mode/pay-bill/.+/confirm').hasMatch(route)) {
    return 'Confirmación de pago';
  }
  return 'Pantalla desconocida';
}
