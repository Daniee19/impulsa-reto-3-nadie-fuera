import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/domain/entities/contract_summary.dart';

/// Contract for contract summary data access.
abstract class ContractRepository {
  /// Returns a contract summary by id.
  ContractSummary getContractSummary(String id);

  /// Returns all available contracts.
  List<ContractSummary> getAllContracts();
}
