import 'package:country_picker/country_picker.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/services/phone_util.service.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/views/pages/parcel/widgets/parcel_form_input.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:fuodz/widgets/error_boundary.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PackageStopRecipientView extends StatefulWidget {
  const PackageStopRecipientView(
    this.stop,
    this.recipientNameTEC,
    this.recipientPhoneTEC,
    this.noteTEC, {
    Key? key,
    this.isOpen = false,
    this.viewKey,
    this.index = 1,
  }) : super(key: key);

  final DeliveryAddress stop;
  final TextEditingController recipientNameTEC;
  final TextEditingController recipientPhoneTEC;
  final TextEditingController noteTEC;
  final bool isOpen;
  final Key? viewKey;
  final int index;

  @override
  _PackageStopRecipientViewState createState() =>
      _PackageStopRecipientViewState();
}

class _PackageStopRecipientViewState extends State<PackageStopRecipientView> {
  //
  bool isOpen = true;
  //customization
  Country selectedCountry = Country.parse("us");

  @override
  void initState() {
    super.initState();
    isOpen = widget.isOpen;
    String countryCode = PhoneUtilService.countryCode ?? "us";
    selectedCountry = Country.parse(countryCode);
  }

  //
  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child:
          VStack([
                //
                HStack([
                  "${widget.index}".text
                      .color(Utils.textColorByTheme())
                      .make()
                      .p12()
                      .box
                      .color(AppColor.primaryColor)
                      .roundedFull
                      .make(),
                  UiSpacer.hSpace(10),
                  VStack([
                    "Contact Info".tr().text.xl.semiBold.make(),
                    "(${widget.stop.name})".text.base.medium
                        .maxLines(2)
                        .ellipsis
                        .make(),
                  ]).expand(),
                  UiSpacer.hSpace(10),
                  Icon(
                    isOpen
                        ? FlutterIcons.caret_down_faw
                        : FlutterIcons.caret_up_faw,
                    color: AppColor.primaryColor,
                  ),
                ], crossAlignment: CrossAxisAlignment.start).onInkTap(() {
                  //
                  setState(() {
                    isOpen = !isOpen;
                  });
                }),

                //
                Visibility(
                  // key: widget.viewKey,
                  visible: isOpen,
                  child: VStack(
                    [
                      UiSpacer.verticalSpace(),

                      //name
                      ParcelFormInput(
                        isReadOnly: false,
                        iconData: FlutterIcons.user_fea,
                        iconColor: AppColor.primaryColor,
                        labelText: "Name".tr().toUpperCase(),
                        hintText: "Contact Name".tr(),
                        tec: widget.recipientNameTEC,
                        formValidator:
                            (value) => FormValidator.validateCustom(
                              value,
                              name: "Name".tr(),
                            ),
                      ),
                      UiSpacer.formVerticalSpace(),

                      //phone
                      ParcelFormInput(
                        isReadOnly: false,
                        iconData: FlutterIcons.phone_fea,
                        iconColor: AppColor.primaryColor,
                        labelText: "phone".tr().toUpperCase(),
                        hintText: "Contact Phone number".tr(),
                        keyboardType: TextInputType.phone,
                        tec: widget.recipientPhoneTEC,
                        formValidator:
                            (value) => FormValidator.validatePhone(
                              value,
                              name: "phone".tr().allWordsCapitilize(),
                            ),
                        content: CustomTextFormField(
                          prefixIcon: Flag.fromString(
                            selectedCountry.countryCode,
                            width: 16,
                            height: 16,
                          ).px8().onInkTap(() {
                            _showCountryDialPicker();
                          }),
                          //
                          maxLines: 1,
                          hintText: "Contact Phone number".tr(),
                          isReadOnly: false,
                          underline: true,
                          onTap: () {},
                          textEditingController: widget.recipientPhoneTEC,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          validator:
                              (value) => FormValidator.validatePhone(
                                value,
                                name: "phone".tr().allWordsCapitilize(),
                              ),
                        ).wFull(context),
                      ),

                      UiSpacer.formVerticalSpace(),

                      //note
                      ParcelFormInput(
                        isReadOnly: false,
                        iconData: FlutterIcons.note_oct,
                        iconColor: AppColor.primaryColor,
                        labelText: "Note".tr().toUpperCase(),
                        hintText: "Further instruction".tr(),
                        tec: widget.noteTEC,
                      ),
                    ],
                    //
                  ),
                ),
              ])
              .p12()
              .box
              .p12
              .py4
              .border(color: AppColor.primaryColor)
              .roundedSM
              .make(),
    );
  }

  //
  _showCountryDialPicker() async {
    //
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: _countryCodeSelected,
    );
  }

  _countryCodeSelected(Country country) {
    //remove previous country code from phone number
    widget.recipientPhoneTEC.text = widget.recipientPhoneTEC.text.replaceAll(
      "+${selectedCountry.phoneCode}",
      "",
    );
    //add new country code
    widget.recipientPhoneTEC.text =
        "+${country.phoneCode}${widget.recipientPhoneTEC.text}";
    //update state
    setState(() {
      selectedCountry = country;
    });
  }
}
