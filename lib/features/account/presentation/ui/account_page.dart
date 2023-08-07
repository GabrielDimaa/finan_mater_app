import 'package:finan_master_app/features/account/domain/entities/account_entity.dart';
import 'package:finan_master_app/features/account/domain/enums/financial_institution_enum.dart';
import 'package:finan_master_app/features/account/presentation/notifiers/account_notifier.dart';
import 'package:finan_master_app/features/account/presentation/states/account_state.dart';
import 'package:finan_master_app/features/account/presentation/ui/components/financial_institutions.dart';
import 'package:finan_master_app/shared/classes/form_result_navigation.dart';
import 'package:finan_master_app/shared/extensions/double_extension.dart';
import 'package:finan_master_app/shared/extensions/string_extension.dart';
import 'package:finan_master_app/shared/presentation/mixins/theme_context.dart';
import 'package:finan_master_app/shared/presentation/ui/app_locale.dart';
import 'package:finan_master_app/shared/presentation/ui/components/error_dialog.dart';
import 'package:finan_master_app/shared/presentation/ui/components/form/mask/mask_input_formatter.dart';
import 'package:finan_master_app/shared/presentation/ui/components/form/validators/input_required_validator.dart';
import 'package:finan_master_app/shared/presentation/ui/components/group_tile.dart';
import 'package:finan_master_app/shared/presentation/ui/components/sliver/sliver_app_bar.dart';
import 'package:finan_master_app/shared/presentation/ui/components/sliver/sliver_scaffold.dart';
import 'package:finan_master_app/shared/presentation/ui/components/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AccountPage extends StatefulWidget {
  static const route = 'account';

  final AccountEntity? account;

  const AccountPage({Key? key, this.account}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with ThemeContext {
  final AccountNotifier notifier = GetIt.I.get<AccountNotifier>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool get isLoading => notifier.value is SavingAccountState || notifier.value is DeletingAccountState;

  @override
  void initState() {
    super.initState();

    if (widget.account != null) notifier.updateAccount(widget.account!);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (_, state, __) {
        return SliverScaffold(
          appBar: SliverAppBarMedium(
            title: Text(strings.account),
            loading: isLoading,
            actions: [
              FilledButton(
                onPressed: save,
                child: Text(strings.save),
              ),
              if (!state.account.isNew)
                IconButton(
                  tooltip: strings.delete,
                  onPressed: delete,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          body: Form(
            key: formKey,
            child: Column(
              children: [
                const Spacing.y(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    initialValue: state.account.initialValue.moneyWithoutSymbol,
                    decoration: InputDecoration(
                      label: Text(strings.initialValue),
                      prefixText: NumberFormat.simpleCurrency(locale: R.locale.toString()).currencySymbol,
                    ),
                    validator: InputRequiredValidator().validate,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading && state.account.isNew,
                    onSaved: (String? value) => state.account.initialValue = (value ?? '').moneyToDouble(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, MaskInputFormatter.currency()],
                  ),
                ),
                const Spacing.y(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    initialValue: state.account.description,
                    decoration: InputDecoration(label: Text(strings.description)),
                    textCapitalization: TextCapitalization.sentences,
                    validator: InputRequiredValidator().validate,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    onSaved: (String? value) => state.account.description = value ?? '',
                  ),
                ),
                const Spacing.y(),
                const Divider(),
                GroupTile(
                  title: strings.financialInstitution,
                  onTap: selectFinancialInstituition,
                  enabled: !isLoading,
                  tile: state.account.financialInstitution == null
                      ? ListTile(
                          leading: const Icon(Icons.account_balance_outlined),
                          title: Text(strings.selectFinancialInstitution),
                          trailing: const Icon(Icons.chevron_right),
                          enabled: !isLoading,
                        )
                      : ListTile(
                          leading: state.account.financialInstitution?.icon,
                          title: Text(state.account.financialInstitution?.description ?? ''),
                          trailing: const Icon(Icons.chevron_right),
                          enabled: !isLoading,
                        ),
                ),
                const Divider(),
                SwitchListTile(
                  title: Text(strings.includeTotalBalance),
                  subtitle: Text(strings.includeTotalBalanceExplication),
                  value: state.account.includeTotalBalance,
                  onChanged: isLoading ? null : notifier.setIncludeTotalBalance,
                ),
                const Divider(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> save() async {
    if (isLoading) return;

    try {
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();

        await notifier.save();

        if (!mounted) return;
        context.pop(FormResultNavigation.save(notifier.account));
      }
    } catch (e) {
      await ErrorDialog.show(context, e.toString());
    }
  }

  Future<void> delete() async {
    if (isLoading) return;

    try {
      await notifier.delete();

      if (!mounted) return;
      context.pop(FormResultNavigation<AccountEntity>.delete());
    } catch (e) {
      await ErrorDialog.show(context, e.toString());
    }
  }

  Future<void> selectFinancialInstituition() async {
    final FinancialInstitutionEnum? financialInstitution = await FinancialInstitutions.show(context: context, financialInstitution: notifier.account.financialInstitution);
    if (financialInstitution == null) return;

    notifier.setFinancialInstitution(financialInstitution);
  }
}
