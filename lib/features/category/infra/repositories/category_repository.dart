import 'package:finan_master_app/features/category/domain/entities/category_entity.dart';
import 'package:finan_master_app/features/category/domain/repositories/i_category_repository.dart';
import 'package:finan_master_app/features/category/helpers/factories/category_factory.dart';
import 'package:finan_master_app/features/category/infra/data_sources/i_category_data_source.dart';
import 'package:finan_master_app/features/category/infra/models/category_model.dart';

class CategoryRepository implements ICategoryRepository {
  final ICategoryDataSource _dataSource;

  CategoryRepository({required ICategoryDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<List<CategoryEntity>> findAll() async {
    final List<CategoryModel> categories = await _dataSource.findAll();
    return categories.map((c) => CategoryFactory.toEntity(c)).toList();
  }

  @override
  Future<CategoryEntity?> findById(String id) async {
    final CategoryModel? category = await _dataSource.findById(id);
    if (category == null) return null;

    return CategoryFactory.toEntity(category);
  }

  @override
  Future<CategoryEntity> save(CategoryEntity entity) async {
    final CategoryModel category = await _dataSource.upsert(CategoryFactory.fromEntity(entity));
    return CategoryFactory.toEntity(category);
  }

  @override
  Future<void> delete(CategoryEntity entity) => _dataSource.delete(CategoryFactory.fromEntity(entity));
}
