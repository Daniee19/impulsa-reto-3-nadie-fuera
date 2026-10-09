import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/domain/entities/lesson.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/domain/repositories/lesson_repository.dart';

class MockLessonRepository implements LessonRepository {
  static const _lessons = [
    Lesson(
      id: 'fake_yape',
      title: 'El Yape falso',
      content:
          'Alguien te escribe diciendo que te mandó dinero '
          'por error. Te pide que se lo devuelvas. '
          'Pero nunca te enviaron nada. Es una estafa común. '
          'Antes de devolver dinero, revisa tu saldo real '
          'en la app. Si no entró nada, no devuelvas nada.',
      relatedRiskRules: {RiskRule.newRecipient},
      question: PracticeQuestion(
        prompt:
            'Te escriben diciendo que te enviaron dinero '
            'por error. ¿Qué haces?',
        options: [
          AnswerOption(
            text: 'Devuelvo el dinero para ser amable',
            isCorrect: false,
            feedback:
                'Cuidado: si devuelves sin revisar, '
                'pierdes tu dinero. Primero verifica tu saldo.',
          ),
          AnswerOption(
            text: 'Reviso mi saldo real antes de hacer nada',
            isCorrect: true,
            feedback:
                '¡Bien hecho! Siempre revisa tu saldo. '
                'Si no recibiste nada, es una estafa.',
          ),
          AnswerOption(
            text: 'Les doy mi clave para que lo arreglen',
            isCorrect: false,
            feedback:
                'Nunca compartas tu clave con nadie. '
                'Ni el banco te la pide. '
                'La mejor opción es revisar tu saldo.',
          ),
        ],
      ),
    ),
    Lesson(
      id: 'bank_call_scam',
      title: 'Llamadas del banco pidiendo claves',
      content:
          'Te llaman diciendo que son del banco. '
          'Te dicen que hay un problema con tu cuenta. '
          'Te piden tu clave o tu número de tarjeta. '
          'Un banco de verdad nunca te pide esos datos '
          'por teléfono. Si recibes esa llamada, cuelga '
          'y llama tú al número oficial del banco.',
      relatedRiskRules: {RiskRule.unusualAmount, RiskRule.unusualTime},
      question: PracticeQuestion(
        prompt:
            'Te llaman diciendo que son del banco y piden '
            'tu clave. ¿Qué haces?',
        options: [
          AnswerOption(
            text: 'Cuelgo y llamo yo al banco',
            isCorrect: true,
            feedback:
                '¡Correcto! Si el banco necesita algo, '
                'tú lo llamas al número oficial.',
          ),
          AnswerOption(
            text:
                'Les doy mis datos para solucionar '
                'el problema',
            isCorrect: false,
            feedback:
                'Cuidado: un banco real nunca pide '
                'tu clave por teléfono. Si diste tus datos, '
                'llama al banco de inmediato.',
          ),
          AnswerOption(
            text: 'Les pido que me manden un correo',
            isCorrect: false,
            feedback:
                'Los estafadores también envían correos '
                'falsos. Lo más seguro es llamar tú al banco.',
          ),
        ],
      ),
    ),
    Lesson(
      id: 'fake_prize',
      title: 'El premio que no existe',
      content:
          'Recibes un mensaje diciendo que ganaste '
          'un premio o un sorteo. Te piden que pagues '
          'un monto pequeño para recibirlo. '
          'Nadie regala premios así. Si no participaste '
          'en un sorteo, no puedes ganar. Los premios '
          'reales nunca te cobran para recibirlos.',
      relatedRiskRules: {RiskRule.highFrequency},
      question: PracticeQuestion(
        prompt:
            'Recibes un mensaje diciendo que ganaste '
            'un premio. ¿Qué haces?',
        options: [
          AnswerOption(
            text: 'Pago lo que piden porque es poco dinero',
            isCorrect: false,
            feedback:
                'Aunque sea poco, es una estafa. '
                'Después te pedirán más. '
                'Nadie regala premios cobrando.',
          ),
          AnswerOption(
            text: 'Comparto mis datos para recibir el premio',
            isCorrect: false,
            feedback:
                'Nunca compartas tus datos por un premio. '
                'Los estafadores los usan para robarte.',
          ),
          AnswerOption(
            text:
                'Lo ignoro porque no participé '
                'en ningún sorteo',
            isCorrect: true,
            feedback:
                '¡Exacto! Si no participaste, '
                'no hay premio. '
                'Los sorteos reales no te cobran.',
          ),
        ],
      ),
    ),
    Lesson(
      id: 'fake_relative',
      title: 'El familiar en apuros',
      content:
          'Te llaman o escriben haciéndose pasar '
          'por un familiar. Dicen que están en una '
          'emergencia y necesitan dinero urgente. '
          'Te piden que envíes dinero rápido sin '
          'contárselo a nadie. Antes de enviar, '
          'llama directamente a tu familiar para confirmar.',
      relatedRiskRules: {RiskRule.newRecipient},
      question: PracticeQuestion(
        prompt:
            'Un "familiar" te pide dinero urgente '
            'por mensaje. ¿Qué haces?',
        options: [
          AnswerOption(
            text:
                'Envío el dinero rápido porque '
                'es una emergencia',
            isCorrect: false,
            feedback:
                'Las estafas usan la urgencia para '
                'que no pienses. Siempre confirma primero.',
          ),
          AnswerOption(
            text:
                'Llamo directamente a mi familiar '
                'para confirmar',
            isCorrect: true,
            feedback:
                '¡Muy bien! Siempre verifica llamando '
                'tú. Los estafadores no quieren '
                'que hagas eso.',
          ),
          AnswerOption(
            text: 'Le pido más detalles por el mismo mensaje',
            isCorrect: false,
            feedback:
                'Los estafadores pueden inventar '
                'detalles. Lo seguro es llamar '
                'directamente a tu familiar.',
          ),
        ],
      ),
    ),
    Lesson(
      id: 'sms_phishing',
      title: 'Enlaces peligrosos por mensaje',
      content:
          'Recibes un mensaje de texto con un enlace. '
          'Dice que tu cuenta será bloqueada si no entras '
          'ahora. Los bancos no bloquean cuentas por '
          'mensaje. Esos enlaces te llevan a páginas falsas '
          'que roban tus datos. Nunca toques enlaces '
          'de mensajes que no esperabas.',
      relatedRiskRules: {RiskRule.unusualTime},
      question: PracticeQuestion(
        prompt:
            'Recibes un mensaje con un enlace diciendo '
            'que tu cuenta será bloqueada. ¿Qué haces?',
        options: [
          AnswerOption(
            text: 'Toco el enlace para ver qué pasa',
            isCorrect: false,
            feedback:
                'Esos enlaces llevan a páginas falsas '
                'que roban tus datos. Nunca los abras.',
          ),
          AnswerOption(
            text:
                'Le reenvío el mensaje a un amigo '
                'para que me ayude',
            isCorrect: false,
            feedback:
                'No reenvíes mensajes sospechosos. '
                'Podrías exponer a otros.',
          ),
          AnswerOption(
            text: 'Borro el mensaje y lo ignoro',
            isCorrect: true,
            feedback:
                '¡Correcto! Los bancos nunca te piden '
                'datos por mensaje. Si tienes duda, '
                'llama al banco.',
          ),
        ],
      ),
    ),
  ];

  @override
  List<Lesson> getAllLessons() => _lessons;

  @override
  Lesson getLessonById(String id) => _lessons.firstWhere((l) => l.id == id);

  @override
  List<Lesson> getLessonsForRules(Set<RiskRule> rules) {
    return _lessons
        .where((l) => l.relatedRiskRules.any(rules.contains))
        .toList();
  }
}
