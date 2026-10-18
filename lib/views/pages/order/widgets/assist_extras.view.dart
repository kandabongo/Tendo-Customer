import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/assist_invoice.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/requests/assist_extras.request.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/views/pages/order/widgets/order_details_card.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

/// Extra charges on an Assist job: additional work the provider asks for (the customer approves
/// or rejects it here - nothing is charged before they approve) and materials the provider
/// added. Hidden when the job has neither. All figures come from the server.
class AssistExtrasView extends StatefulWidget {
  const AssistExtrasView({required this.order, Key? key}) : super(key: key);

  final Order order;

  @override
  State<AssistExtrasView> createState() => _AssistExtrasViewState();
}

class _AssistExtrasViewState extends State<AssistExtrasView> {
  final AssistExtrasRequest _request = AssistExtrasRequest();

  AssistInvoice? _invoice;
  bool _busy = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    //a request can arrive while the customer is looking at the job
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!_busy && !(_invoice?.locked ?? false)) {
        _load();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final invoice = await _request.getInvoice(widget.order.id);
      if (!mounted) return;
      setState(() => _invoice = invoice);
    } catch (_) {
      //keep showing the last figures; the next refresh will try again
    }
  }

  String _money(double amount) =>
      "${AppStrings.currencySymbol} ${amount.toStringAsFixed(2)}";

  Future<void> _answer(AssistExtraWork work, bool approve) async {
    if (_busy) return; //repeated taps
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(approve ? "Approve additional work?".tr() : "Reject additional work?".tr()),
            content: Text(
              approve
                  ? "${work.description}\n\n${"You will be charged".tr()} ${_money(work.amount)}."
                  : work.description,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text("Cancel".tr()),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(approve ? "Approve".tr() : "Reject".tr()),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await _request.respond(additionalWorkId: work.id, approve: approve);
      ToastService.toastSuccessful(
        approve ? "Additional work approved".tr() : "Additional work rejected".tr(),
      );
    } catch (error) {
      ToastService.toastError("$error");
    }
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 16 : 14,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color = Colors.orange;
    String text = "Waiting for your answer".tr();
    if (status == "approved") {
      color = Colors.green;
      text = "Approved".tr();
    } else if (status == "rejected") {
      color = Colors.red;
      text = "Rejected".tr();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoice = _invoice;
    if (invoice == null ||
        (invoice.extraWorkItems.isEmpty && invoice.materialItems.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: OrderDetailsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Additional charges".tr(),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),

            for (final work in invoice.extraWorkItems)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: work.isPending ? Colors.orange : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(work.description)),
                        Text(
                          _money(work.amount),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _statusChip(work.status),
                    if (work.isPending && !invoice.locked) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _busy ? null : () => _answer(work, false),
                              child: Text("Reject".tr()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _busy ? null : () => _answer(work, true),
                              child: Text("Approve".tr()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

            if (invoice.materialItems.isNotEmpty) ...[
              Text("Materials".tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
              for (final item in invoice.materialItems)
                _row(
                  "${item.name} (${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 2)}"
                  "${item.unit.isNotEmpty ? " ${item.unit}" : ""})",
                  _money(item.total),
                ),
              const SizedBox(height: 6),
            ],

            const Divider(),
            _row("Service".tr(), _money(invoice.service)),
            if (invoice.additionalWork > 0)
              _row("Additional work".tr(), _money(invoice.additionalWork)),
            if (invoice.materials > 0) _row("Materials".tr(), _money(invoice.materials)),
            if (invoice.transport > 0) _row("Transport".tr(), _money(invoice.transport)),
            _row("Total".tr(), _money(invoice.total), bold: true),
            if (invoice.additionalWorkPending > 0)
              _row(
                "Not included until you approve".tr(),
                _money(invoice.additionalWorkPending),
                color: Colors.orange,
              ),
          ],
        ),
      ),
    );
  }
}
