import 'package:flutter/material.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/view_models/property_chat.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class PropertyChatPage extends StatelessWidget {
  const PropertyChatPage({required this.property, Key? key}) : super(key: key);

  final Property property;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PropertyChatViewModel>.reactive(
      viewModelBuilder: () => PropertyChatViewModel(context, property),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          title: "Chat with Host".tr(),
          showAppBar: true,
          showLeadingAction: true,
          isLoading: model.isBusy,
          body: Column(
            children: [
              // Chat Messages Area (Placeholder)
              Expanded(
                child:
                    model.messages.isEmpty
                        ? Center(
                          child: Text(
                            "Start a conversation with the host.".tr(),
                          ),
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: model.messages.length,
                          separatorBuilder:
                              (context, index) => UiSpacer.verticalSpace(),
                          itemBuilder: (context, index) {
                            // Placeholder for message item
                            final message = model.messages[index];
                            return Text(message).p8().card.make();
                          },
                        ),
              ),

              // Message Input Area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        hintText: "Type a message...".tr(),
                        textEditingController: model.messageController,
                        minLines: 1,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: model.sendMessage,
                      icon: Icon(Icons.send, color: AppColor.primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
