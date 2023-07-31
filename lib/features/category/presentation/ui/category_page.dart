import 'package:finan_master_app/features/category/domain/entities/category_entity.dart';
import 'package:finan_master_app/features/category/domain/enums/category_type_enum.dart';
import 'package:finan_master_app/features/category/presentation/notifiers/category_notifier.dart';
import 'package:finan_master_app/features/category/presentation/states/category_state.dart';
import 'package:finan_master_app/features/category/presentation/ui/components/color_and_icon_category.dart';
import 'package:finan_master_app/shared/extensions/int_extension.dart';
import 'package:finan_master_app/shared/extensions/string_extension.dart';
import 'package:finan_master_app/shared/presentation/mixins/theme_context.dart';
import 'package:finan_master_app/shared/presentation/ui/components/error_dialog.dart';
import 'package:finan_master_app/shared/presentation/ui/components/form/validators/input_required_validator.dart';
import 'package:finan_master_app/shared/presentation/ui/components/group_tile.dart';
import 'package:finan_master_app/shared/presentation/ui/components/sliver/sliver_app_bar.dart';
import 'package:finan_master_app/shared/presentation/ui/components/sliver/sliver_scaffold.dart';
import 'package:finan_master_app/shared/presentation/ui/components/spacing.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class CategoryPage extends StatefulWidget {
  static const route = 'category';

  final CategoryEntity? category;

  const CategoryPage({Key? key, this.category}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> with ThemeContext {
  final CategoryNotifier notifier = GetIt.I.get<CategoryNotifier>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) notifier.updateCategory(widget.category!);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (_, state, __) {
        return SliverScaffold(
          appBar: SliverAppBarMedium(
            title: Text(strings.category),
            loading: state is SavingCategoryState || state is DeletingCategoryState,
            actions: [
              FilledButton(
                onPressed: save,
                child: Text(strings.save),
              ),
              if (state.category.createdAt != null)
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacing.y(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    initialValue: state.category.description,
                    decoration: InputDecoration(label: Text(strings.description)),
                    textCapitalization: TextCapitalization.sentences,
                    validator: InputRequiredValidator().validate,
                    onSaved: (String? value) => state.category.description = value ?? '',
                  ),
                ),
                const Spacing.y(),
                const Divider(),
                const Spacing.y(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(strings.typeCategory, style: textTheme.bodySmall),
                ),
                RadioListTile<CategoryTypeEnum>(
                  title: Text(CategoryTypeEnum.expense.description),
                  value: CategoryTypeEnum.expense,
                  groupValue: state.category.type,
                  onChanged: notifier.setType,
                ),
                RadioListTile<CategoryTypeEnum>(
                  title: Text(CategoryTypeEnum.income.description),
                  value: CategoryTypeEnum.income,
                  groupValue: state.category.type,
                  onChanged: notifier.setType,
                ),
                const Divider(),
                GroupTile(
                  onTap: selectColorAndIcon,
                  title: strings.typeCategory,
                  tile: state.category.color.isNotEmpty && state.category.icon > 0
                      ? ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(state.category.color.toColor() ?? 0),
                            child: Icon(state.category.icon.parseIconData()),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        )
                      : ListTile(
                          leading: const Icon(Icons.palette_outlined),
                          title: Text(strings.icon),
                          trailing: const Icon(Icons.chevron_right),
                        ),
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
    try {
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();

        await notifier.save();

        if (!mounted) return;
        context.pop(notifier.category);
      }
    } catch (e) {
      await ErrorDialog.show(context, e.toString());
    }
  }

  Future<void> delete() async {
    try {
      await notifier.delete();

      if (!mounted) return;
      context.pop();
    } catch (e) {
      await ErrorDialog.show(context, e.toString());
    }
  }

  Future<void> selectColorAndIcon() async {
    final ({Color color, IconData icon})? result = await ColorAndIconCategory.show(
      context: context,
      color: notifier.category.color.isNotEmpty ? Color(notifier.category.color.toColor()!) : null,
      icon: notifier.category.icon > 0 ? notifier.category.icon.parseIconData() : null,
    );
    if (result == null) return;

    notifier.setColorIcon(color: result.color.value.toRadixString(16), icon: result.icon.codePoint);
  }
}
