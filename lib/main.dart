import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/app.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/data/repositories/mock_account_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/data/repositories/mock_bill_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/data/repositories/mock_contact_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/data/repositories/mock_operation_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/account_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/bill_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/contact_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/operation_provider.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        accountRepositoryProvider
            .overrideWithValue(MockAccountRepository()),
        billRepositoryProvider
            .overrideWithValue(MockBillRepository()),
        contactRepositoryProvider
            .overrideWithValue(MockContactRepository()),
        operationRepositoryProvider
            .overrideWithValue(MockOperationRepository()),
      ],
      child: const App(),
    ),
  );
}
