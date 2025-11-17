import 'package:stock/domain/usecases/delivery/register_delivery_usecase.dart';
import 'package:stock/presentation/pages/sales/delivery/delivery_dialog.dart';

import '../../data/model/delivery.dart';

abstract class IDeliveryRepository {
  Future<void> registerDelivery({
    required String saleId,
    required DeliveryData data,
  });

  Future<DeliveryData?> getDelivery({required String saleId});
}
