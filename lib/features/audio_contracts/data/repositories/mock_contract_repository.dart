import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/domain/entities/contract_summary.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/domain/repositories/contract_repository.dart';

/// Static contract data for demo purposes.
class MockContractRepository implements ContractRepository {
  static const _savings = ContractSummary(
    id: 'savings_account',
    title: 'Cuenta de ahorro básica',
    sections: [
      ContractSection(
        type: ContractSectionType.whatYouAccept,
        title: 'Qué aceptas',
        content: 'Abres una cuenta de ahorro. El banco guarda tu dinero.',
      ),
      ContractSection(
        type: ContractSectionType.cost,
        title: 'Cuánto cuesta',
        content:
            'No tiene costo mensual. Sacar dinero de otro banco cuesta un sol.',
      ),
      ContractSection(
        type: ContractSectionType.risks,
        title: 'Qué puede salir mal',
        content:
            'Tu dinero está protegido. '
            'Si el banco cierra, el gobierno te devuelve '
            'hasta cien mil soles.',
      ),
      ContractSection(
        type: ContractSectionType.howToCancel,
        title: 'Cómo cancelar',
        content:
            'Puedes cerrar tu cuenta cuando quieras. '
            'Ve a una oficina o llama. '
            'No cobran por cerrarla.',
      ),
    ],
    fullContractParagraphs: [
      'CONTRATO DE CUENTA DE AHORRO BÁSICA.',
      'Usted abre una cuenta de ahorro en nuestro banco.',
      'No cobramos mantenimiento mensual por esta cuenta.',
      'Puede hacer retiros en cualquier cajero de nuestra red sin costo.',
      'Los retiros en cajeros de otros bancos tienen un costo de un sol.',
      'Su dinero está protegido por el Fondo de Seguro de Depósitos.',
      'La cobertura máxima es de cien mil soles por persona.',
      'Puede cerrar su cuenta en cualquier momento sin penalidad.',
    ],
  );

  static const _loan = ContractSummary(
    id: 'personal_loan',
    title: 'Préstamo personal',
    sections: [
      ContractSection(
        type: ContractSectionType.whatYouAccept,
        title: 'Qué aceptas',
        content:
            'El banco te presta dinero. '
            'Tú lo devuelves poco a poco cada mes.',
      ),
      ContractSection(
        type: ContractSectionType.cost,
        title: 'Cuánto cuesta',
        content:
            'Pagas lo que pediste más un interés. '
            'El interés es quince por ciento al año.',
      ),
      ContractSection(
        type: ContractSectionType.risks,
        title: 'Qué puede salir mal',
        content:
            'Si no pagas a tiempo, cobran una multa. '
            'También puede afectar tu historial.',
      ),
      ContractSection(
        type: ContractSectionType.howToCancel,
        title: 'Cómo cancelar',
        content:
            'Puedes pagar todo lo que debes '
            'de una vez. Llama al banco para pedir '
            'el monto exacto.',
      ),
    ],
    fullContractParagraphs: [
      'CONTRATO DE PRÉSTAMO PERSONAL.',
      'El banco le otorga un préstamo por el monto solicitado.',
      'El plazo de pago se acuerda al momento de la firma.',
      'La tasa de interés es quince por ciento anual.',
      'Las cuotas se pagan mensualmente en la fecha acordada.',
      'Si se atrasa en el pago, se cobra una penalidad.',
      'La penalidad es del dos por ciento del monto atrasado.',
      'Puede realizar pagos adelantados sin penalidad.',
      'Para cancelar el préstamo, debe pagar el saldo total.',
      'Contacte al banco para conocer su saldo exacto.',
    ],
  );

  static const _contracts = [_savings, _loan];

  @override
  ContractSummary getContractSummary(String id) {
    return _contracts.firstWhere((c) => c.id == id);
  }

  @override
  List<ContractSummary> getAllContracts() => _contracts;
}
