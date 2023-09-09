import 'package:collection/collection.dart';
import 'package:finan_master_app/features/account/domain/entities/account_entity.dart';
import 'package:finan_master_app/features/account/domain/enums/financial_institution_enum.dart';
import 'package:finan_master_app/features/account/presentation/notifiers/accounts_notifier.dart';
import 'package:finan_master_app/features/account/presentation/states/accounts_state.dart';
import 'package:finan_master_app/features/account/presentation/ui/components/accounts_list_bottom_sheet.dart';
import 'package:finan_master_app/features/category/domain/entities/category_entity.dart';
import 'package:finan_master_app/features/category/domain/enums/category_type_enum.dart';
import 'package:finan_master_app/features/category/presentation/notifiers/categories_notifier.dart';
import 'package:finan_master_app/features/category/presentation/states/categories_state.dart';
import 'package:finan_master_app/features/category/presentation/ui/components/categories_list_bottom_sheet.dart';
import 'package:finan_master_app/features/transactions/domain/entities/expense_entity.dart';
import 'package:finan_master_app/features/transactions/presentation/notifiers/expense_notifier.dart';
import 'package:finan_master_app/shared/classes/form_result_navigation.dart';
import 'package:finan_master_app/shared/extensions/double_extension.dart';
import 'package:finan_master_app/shared/extensions/int_extension.dart';
import 'package:finan_master_app/shared/extensions/string_extension.dart';
import 'package:finan_master_app/shared/presentation/mixins/theme_context.dart';
import 'package:finan_master_app/shared/presentation/ui/app_locale.dart';
import 'package:finan_master_app/shared/presentation/ui/components/dialog/error_dialog.dart';
import 'package:finan_master_app/shared/presentation/ui/components/form/mask/mask_input_formatter.dart';
import 'package:finan_master_app/shared/presentation/ui/components/form/validators/input_greater_than_value.dart';
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

class ExpenseFormPage extends StatefulWidget {
  static const route = 'expense-form';

  final ExpenseEntity? expense;

  const ExpenseFormPage({Key? key, this.expense}) : super(key: key);

  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> with ThemeContext {
  final ExpenseNotifier notifier = GetIt.I.get<ExpenseNotifier>();
  final CategoriesNotifier categoriesNotifier = GetIt.I.get<CategoriesNotifier>();
  final AccountsNotifier accountsNotifier = GetIt.I.get<AccountsNotifier>();

  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    dateController.text = DateFormat.yMd(AppLocale().locale.languageCode).format(notifier.expense.transaction.date);

    Future(() async {
      try {
        loadingNotifier.value = true;

        await Future.wait([
          categoriesNotifier.findAll(type: CategoryTypeEnum.expense),
          accountsNotifier.findAll(),
        ]);
      } finally {
        loadingNotifier.value = false;
      }

      if (!mounted) return;

      if (categoriesNotifier.value is ErrorCategoriesState) {
        ErrorDialog.show(context, (categoriesNotifier.value as ErrorCategoriesState).message);
      }

      if (accountsNotifier.value is ErrorAccountsState) {
        ErrorDialog.show(context, (accountsNotifier.value as ErrorAccountsState).message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: loadingNotifier,
      builder: (_, loading, __) {
        return SliverScaffold(
          appBar: SliverAppBarMedium(
            title: Text(strings.expense),
            loading: loading,
            actions: [
              FilledButton(
                onPressed: save,
                child: Text(strings.save),
              ),
              if (widget.expense?.isNew == false)
                IconButton(
                  tooltip: strings.delete,
                  onPressed: null,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          body: Builder(
            builder: (_) {
              if (loading) return const SizedBox.shrink();

              return ValueListenableBuilder(
                valueListenable: notifier,
                builder: (_, state, __) {
                  return Form(
                    key: formKey,
                    child: Column(
                      children: [
                        const Spacing.y(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              TextFormField(
                                initialValue: state.expense.transaction.amount.moneyWithoutSymbol,
                                decoration: InputDecoration(
                                  label: Text(strings.amount),
                                  prefixText: NumberFormat.simpleCurrency(locale: R.locale.toString()).currencySymbol,
                                ),
                                validator: InputGreaterThanValueValidator().validate,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                enabled: !loading,
                                onSaved: (String? value) => state.expense.transaction.amount = (value ?? '').moneyToDouble(),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, MaskInputFormatter.currency()],
                              ),
                              const Spacing.y(),
                              TextFormField(
                                initialValue: state.expense.description,
                                decoration: InputDecoration(label: Text(strings.description)),
                                textCapitalization: TextCapitalization.sentences,
                                validator: InputRequiredValidator().validate,
                                onSaved: (String? value) => state.expense.description = value?.trim() ?? '',
                                enabled: !loading,
                              ),
                              const Spacing.y(),
                              TextFormField(
                                decoration: InputDecoration(label: Text(strings.date)),
                                readOnly: true,
                                controller: dateController,
                                validator: InputRequiredValidator().validate,
                                enabled: !loading,
                                onTap: selectDate,
                              ),
                            ],
                          ),
                        ),
                        const Spacing.y(),
                        const Divider(),
                        GroupTile(
                          onTap: selectCategory,
                          title: strings.category,
                          enabled: !loading,
                          tile: state.expense.idCategory != null
                              ? Builder(
                                  builder: (_) {
                                    final CategoryEntity category = categoriesNotifier.value.categories.firstWhere((category) => category.id == state.expense.idCategory);
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Color(category.color.toColor() ?? 0),
                                        child: Icon(category.icon.parseIconData(), color: Colors.white),
                                      ),
                                      title: Text(category.description),
                                      trailing: const Icon(Icons.chevron_right),
                                      enabled: !loading,
                                    );
                                  },
                                )
                              : ListTile(
                                  leading: const Icon(Icons.category_outlined),
                                  title: Text(strings.selectCategory),
                                  trailing: const Icon(Icons.chevron_right),
                                  enabled: !loading,
                                ),
                        ),
                        const Divider(),
                        GroupTile(
                          onTap: selectAccount,
                          title: strings.account,
                          enabled: !loading,
                          tile: state.expense.transaction.idAccount != null
                              ? Builder(
                                  builder: (_) {
                                    final AccountEntity account = accountsNotifier.value.accounts.firstWhere((account) => account.id == state.expense.transaction.idAccount);
                                    return ListTile(
                                      leading: account.financialInstitution!.icon(),
                                      title: Text(account.description),
                                      trailing: const Icon(Icons.chevron_right),
                                      enabled: !loading,
                                    );
                                  },
                                )
                              : ListTile(
                                  leading: const Icon(Icons.account_balance_outlined),
                                  title: Text(strings.selectAccount),
                                  trailing: const Icon(Icons.chevron_right),
                                  enabled: !loading,
                                ),
                        ),
                        const Divider(),
                        const Spacing.y(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            initialValue: state.expense.observation,
                            decoration: InputDecoration(label: Text("${strings.observation} (${strings.optional})")),
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 2,
                            maxLines: 5,
                            onSaved: (String? value) => state.expense.observation = value?.trim() ?? '',
                            enabled: !loading,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> save() async {
    if (loadingNotifier.value) return;

    try {
      loadingNotifier.value = true;

      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();

        await notifier.save();

        if (!mounted) return;
        context.pop(FormResultNavigation.save(notifier.expense));
      }
    } catch (e) {
      await ErrorDialog.show(context, e.toString());
    } finally {
      loadingNotifier.value = false;
    }
  }

  Future<void> selectCategory() async {
    if (loadingNotifier.value) return;

    final CategoryEntity? result = await CategoriesListBottomSheet.show(
      context: context,
      categorySelected: categoriesNotifier.value.categories.firstWhereOrNull((category) => category.id == notifier.expense.idCategory),
      categories: categoriesNotifier.value.categories,
    );

    if (result == null) return;

    notifier.setCategory(result.id);
  }

  Future<void> selectAccount() async {
    if (loadingNotifier.value) return;

    final AccountEntity? result = await AccountsListBottomSheet.show(
      context: context,
      accountSelected: accountsNotifier.value.accounts.firstWhereOrNull((category) => category.id == notifier.expense.transaction.idAccount),
      accounts: accountsNotifier.value.accounts,
    );

    if (result == null) return;

    notifier.setAccount(result.id);
  }

  Future<void> selectDate() async {
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: notifier.expense.transaction.date,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );

    if (result == null || result == notifier.expense.transaction.date) return;

    dateController.text = DateFormat.yMd(AppLocale().locale.languageCode).format(result);
    notifier.setDate(result);
  }
}