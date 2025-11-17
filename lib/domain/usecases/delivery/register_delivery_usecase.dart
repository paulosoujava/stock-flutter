import 'package:injectable/injectable.dart';
import 'package:stock/data/model/params_delivery.dart';
import 'package:stock/domain/repositories/idelivery_repository.dart';
import 'package:stock/presentation/pages/sales/delivery/delivery_dialog.dart';

import '../../../data/model/delivery.dart';




@injectable
class RegisterDeliveryUseCase {
  final IDeliveryRepository repository;

  RegisterDeliveryUseCase(this.repository);

  Future<void> call(DeliveryParams params) {
    return repository.registerDelivery(
      saleId: params.saleId,
      data: params.data,
    );
  }
}
