import '../models/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<List<Category>> getCategoriesByType(CategoryType type);
  Future<Category?> getCategoryById(String id);
  Future<void> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<void> initializeDefaultCategories();
}
