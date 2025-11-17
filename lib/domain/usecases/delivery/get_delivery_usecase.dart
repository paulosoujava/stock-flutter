import 'package:injectable/injectable.dart';
import 'package:stock/data/model/delivery.dart';

import '../../repositories/idelivery_repository.dart';

@injectable
class GetDeliveryUseCase {
  final IDeliveryRepository repository;

  GetDeliveryUseCase(this.repository);

  Future<DeliveryData?> call(String saleId ) {
    return repository.getDelivery(
      saleId: saleId,
    );
  }
}
