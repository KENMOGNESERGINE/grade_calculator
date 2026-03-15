import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductViewModel extends ChangeNotifier {
  
  // The list of products (hardcoded)
  final List<Product> products = const [
    Product(id: 1, name: 'Apple iPhone 16', price: 999.99),
    Product(id: 2, name: 'Samsung Galaxy S25', price: 899.99),
    Product(id: 3, name: 'Sony Headphones', price: 349.99),
    Product(id: 4, name: 'MacBook Air M4', price: 1299.99),
    Product(id: 5, name: 'iPad Pro', price: 1099.99),
  ];

  // The product the user tapped on
  Product? _selectedProduct;
  Product? get selectedProduct => _selectedProduct;

  // Called when user taps a product
  void selectProduct(Product product) {
    _selectedProduct = product;
    notifyListeners();
  }
}