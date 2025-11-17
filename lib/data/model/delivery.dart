class DeliveryData {
  final String method;
  final String? customMethod;
  final String? addressId;  // Will use selected address string
  final String status;
  final DateTime? dispatchDate;
  final String? returnReason;
  final String? courierName;
  final String? courierNotes;
  final String? paymentMethod;  // New: if adding as per your description
  final String? customPaymentMethod;  // New

  DeliveryData({
    required this.method,
    this.customMethod,
    this.addressId,
    required this.status,
    this.dispatchDate,
    this.returnReason,
    this.courierName,
    this.courierNotes,
    this.paymentMethod,
    this.customPaymentMethod,
  });

  @override
  String toString() {
    return 'DeliveryData{method: $method, customMethod: $customMethod, addressId: $addressId, status: $status, dispatchDate: $dispatchDate, returnReason: $returnReason, courierName: $courierName, courierNotes: $courierNotes, paymentMethod: $paymentMethod, customPaymentMethod: $customPaymentMethod}';
  }

}