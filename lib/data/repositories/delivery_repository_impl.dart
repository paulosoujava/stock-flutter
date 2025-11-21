import 'package:hive/hive.dart';
import '../../domain/repositories/idelivery_repository.dart';
import '../../presentation/pages/sales/delivery/delivery_dialog.dart';
import '../model/delivery.dart';

const String _kDeliveryBox = 'deliveryBox';

class DeliveryRepositoryImpl implements IDeliveryRepository {
  Box<Map>? _cachedBox;

  Future<Box<Map>> _openBox() async {
    if (_cachedBox?.isOpen ?? false) return _cachedBox!;
    _cachedBox = await Hive.openBox<Map>(_kDeliveryBox);
    return _cachedBox!;
  }

  @override
  Future<void> registerDelivery({
    required String saleId,
    required DeliveryData data,
  }) async {
    final box = await _openBox();

    try {
      final bool isStore = data.method == "Loja";

      final deliveryMap = {
        "saleId": saleId,
        "method": data.method,
        "customMethod": isStore || data.method != "Outro" ? null : data.customMethod?.trim(),

        "addressId": isStore ? null : data.addressId,

        "status": isStore
            ? "Retirada na Loja"
            : data.status,  // ← agora usa o status real (Entregue, Pendente, etc)

        // CORREÇÃO PRINCIPAL: salva a data se o status for "Entregue", independente de qualquer coisa
        "dispatchDate": (data.status == "Entregue" && data.dispatchDate != null)
            ? data.dispatchDate!.toIso8601String()
            : null,

        "returnReason": data.status == "Retornou" ? data.returnReason?.trim() : null,
        "courierName": isStore ? null : data.courierName?.trim(),
        "courierNotes": isStore ? null : data.courierNotes?.trim(),

        "paymentMethod": data.paymentMethod,
        "customPaymentMethod": data.paymentMethod == "Outro" ? data.customPaymentMethod?.trim() : null,

        "createdAt": DateTime.now().toIso8601String(),
      };

      await box.put(saleId, deliveryMap);

      print("Delivery registrada com sucesso: $deliveryMap");
    } catch (e) {
      throw Exception("Erro ao registrar entrega: $e");
    }
  }

  @override
  Future<DeliveryData?> getDelivery({required String saleId}) async {
    final box = await _openBox();
    // 1. Leia o dado do Hive e explicitamente diga que ele é um Map.
    //    O Hive armazena como `Map<dynamic, dynamic>`, então fazemos o cast.
    final deliveryMap = box.get(saleId)?.cast<String, dynamic>();

    // 2. Se o mapa for nulo (nenhum dado encontrado), retorne nulo.
    if (deliveryMap == null) {
      return null;
    }

    // 3. Construa o objeto DeliveryData a partir do Map que você leu do Hive.
    //    Este é o passo que estava faltando e que causava o erro.
    try {
      return DeliveryData(
        method: deliveryMap['method'],
        customMethod: deliveryMap['customMethod'],
        paymentMethod: deliveryMap['paymentMethod'],
        customPaymentMethod: deliveryMap['customPaymentMethod'],
        addressId: deliveryMap['addressId'],
        status: deliveryMap['status'],
        // Converte a data de String de volta para DateTime, se existir.
        dispatchDate: deliveryMap['dispatchDate'] != null
            ? DateTime.tryParse(deliveryMap['dispatchDate'])
            : null,
        returnReason: deliveryMap['returnReason'],
        courierName: deliveryMap['courierName'],
        courierNotes: deliveryMap['courierNotes'],
      );
    } catch (e) {
      // Se houver um erro durante a criação do objeto (ex: campo faltando no mapa antigo),
      // é mais seguro retornar nulo e imprimir o erro para depuração.
      print("Erro ao converter mapa para DeliveryData para a venda $saleId: $e");
      return null;
    }
  }
}
