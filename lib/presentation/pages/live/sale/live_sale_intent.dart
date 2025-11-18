// presentation/viewmodels/live/sale/live_sale_intent.dart
import '../../../../domain/entities/product/product.dart';

abstract class LiveSaleIntent {}

class LoadLiveIntent extends LiveSaleIntent {
  final String liveId;
  LoadLiveIntent(this.liveId);
}

class SearchInstagramIntent extends LiveSaleIntent {}

class RemoveCurrentCustomerIntent extends LiveSaleIntent {
  final int index;
  RemoveCurrentCustomerIntent(this.index);
}

class SelectProductIntent extends LiveSaleIntent {
  final Product? product;
  SelectProductIntent(this.product);
}

class AddOrderIntent extends LiveSaleIntent {}

class RemoveOrderIntent extends LiveSaleIntent {
  final int index;
  RemoveOrderIntent(this.index);
}

class ShowOrderDetailsIntent extends LiveSaleIntent {
  final int index;
  ShowOrderDetailsIntent(this.index);
}

class OpenGlobalDiscountDialogIntent extends LiveSaleIntent {}

class FinalizeLiveIntent extends LiveSaleIntent {}


class SetGlobalDiscountIntent extends LiveSaleIntent {
  final int value;
  SetGlobalDiscountIntent(this.value);
}

