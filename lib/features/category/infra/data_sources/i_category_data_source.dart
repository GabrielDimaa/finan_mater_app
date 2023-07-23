import 'package:finan_master_app/features/category/infra/models/category_model.dart';
import 'package:finan_master_app/shared/infra/data_sources/i_local_data_source.dart';

abstract interface class ICategoryDataSource implements ILocalDataSource<CategoryModel> {}
