import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/src/intl/number_format.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/presentation/pages/sales/sales_view_model.dart';

import '../../../../../core/navigation/app_routes.dart';
import '../../../../../domain/entities/customer/customer.dart';
import '../../../../../domain/entities/sale/sale_item.dart';
import '../../../sales/report/sales_report_intent.dart';

void showCustomerNotRegistered(BuildContext context, Sale sale) {
  final instagram = sale.customerName.split(' ').first;

  final tempCustomer = Customer(
    id: '',
    name: sale.customerName.replaceAll('@', '').split(' ').first,
    instagram: instagram,
    cpf: '',
    email: '',
    phone: '',
    whatsapp: '',
    address: '',
    address1: null,
    address2: null,
  );
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      icon: Icon(Icons.person_off, size: 48, color: Colors.orange.shade700),
      title: Text(
        "Opsss, cliente não cadastrado",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.orange.shade800,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "O cliente \"${sale.customerName}\" foi adicionado na live, e não temos o cadastro completo para exibir, ou  para usar a funcionalidade de delivery.",
              style:
                  GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Text(
              "Ainda assim, a venda foi registrada, mas você precisa cadastra-lo.",
              style:
                  GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.push(AppRoutes.customerEdit, extra: tempCustomer);
            Navigator.pop(ctx);
          },
          child: Text(
            "Cadastrar",
            style: GoogleFonts.poppins(
                color: Colors.deepPurple, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}


void showDeletedCustomer(BuildContext context, Sale sale){
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      icon: Icon(Icons.person_off, size: 48, color: Colors.orange.shade700),
      title: Text(
        "Cliente não encontrado",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.orange.shade800,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "O cliente \"${sale.customerName}\" foi removido do sistema ou não está mais disponível.",
            style: GoogleFonts.poppins(
                fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Text(
            "Ainda assim, a venda continua registrada com o nome salvo na época.",
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            "Entendido",
            style: GoogleFonts.poppins(
                color: Colors.deepPurple, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

// ===============================================================
// POPUP CANCELAMENTO
// ===============================================================

 void openCancelDialog(BuildContext context,  void Function(String reason) onPressed) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text("Cancelar Venda",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: 19)),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Motivo do cancelamento",
              labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.deepPurple),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Voltar",
                  style: GoogleFonts.poppins(color: Colors.grey.shade700))),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onPressed(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: Text("Confirmar Cancelamento",
                style: GoogleFonts.poppins(color: Colors.white)),
          )
        ],
      );
    },
  );
}

// ===============================================================
// POPUP HISTÓRICO
// ===============================================================
void openSaleHistory(BuildContext context, Sale sale, NumberFormat currency) {
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            const Icon(Icons.receipt_long,
                color: Colors.deepPurple, size: 26),
            const SizedBox(width: 10),
            Text("Histórico da Venda",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 19)),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if ((sale.globalDiscount ?? 0) > 0)
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade50, Colors.green.shade100],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.discount,
                            color: Colors.green, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Desconto global: ${sale.globalDiscount}%\n${sale.globalDescription ?? ''}",
                            style: GoogleFonts.poppins(
                                fontSize: 13.5, color: Colors.green.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ...sale.items.map((SaleItem item) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2_outlined,
                          color: Colors.deepPurple),
                      title: Text(item.productName,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "${item.quantity}x ${currency.format(item.pricePerUnit)}",
                              style: GoogleFonts.poppins(fontSize: 13)),
                          if ((item.discount ?? 0) > 0)
                            Text(
                              "Desconto: ${item.discount}%",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      trailing: Text(
                        currency.format(item.quantity * item.pricePerUnit),
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Fechar",
                style: GoogleFonts.poppins(color: Colors.deepPurple)),
          )
        ],
      );
    },
  );
}