import 'dart:math';

// ============================================================
// Models
// ============================================================

class Product {
  final int id;
  String name;
  String category;
  double price;
  int stock;
  bool active;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.active = true,
  });

  double get inventoryValue => price * stock;

  bool get isAvailable => active && stock > 0;

  void updatePrice(double newPrice) {
    if (newPrice < 0) {
      throw ArgumentError('Price cannot be negative');
    }

    price = newPrice;
  }

  void addStock(int quantity) {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }

    stock += quantity;
  }

  void removeStock(int quantity) {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }

    if (stock < quantity) {
      throw StateError('Insufficient stock');
    }

    stock -= quantity;
  }

  void deactivate() {
    active = false;
  }

  void activate() {
    active = true;
  }

  @override
  String toString() {
    return 'Product($id, $name, $category, $price, $stock)';
  }
}

class Customer {
  final int id;
  String name;
  String email;
  String phone;
  int rewardPoints;
  bool active;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.rewardPoints = 0,
    this.active = true,
  });

  void addPoints(int points) {
    if (points < 0) {
      throw ArgumentError('Points cannot be negative');
    }

    rewardPoints += points;
  }

  void usePoints(int points) {
    if (points < 0) {
      throw ArgumentError('Points cannot be negative');
    }

    if (rewardPoints < points) {
      throw StateError('Insufficient reward points');
    }

    rewardPoints -= points;
  }

  void updateEmail(String newEmail) {
    if (!newEmail.contains('@')) {
      throw ArgumentError('Invalid email address');
    }

    email = newEmail;
  }

  void deactivate() {
    active = false;
  }

  @override
  String toString() {
    return 'Customer($id, $name, $email)';
  }
}

class OrderItem {
  final Product product;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => unitPrice * quantity;

  @override
  String toString() {
    return '${product.name} x $quantity = $total';
  }
}

enum OrderStatus {
  pending,
  paid,
  preparing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

class Order {
  final int id;
  final Customer customer;
  final List<OrderItem> items;
  final DateTime createdAt;

  OrderStatus status;
  double discount;
  double shippingFee;

  Order({
    required this.id,
    required this.customer,
    required this.items,
    required this.createdAt,
    this.status = OrderStatus.pending,
    this.discount = 0,
    this.shippingFee = 0,
  });

  double get subtotal {
    return items.fold(
      0.0,
      (sum, item) => sum + item.total,
    );
  }

  double get total {
    return max(
      0.0,
      subtotal - discount + shippingFee,
    );
  }

  int get totalQuantity {
    return items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  void pay() {
    if (status != OrderStatus.pending) {
      throw StateError('Order cannot be paid');
    }

    status = OrderStatus.paid;
  }

  void prepare() {
    if (status != OrderStatus.paid) {
      throw StateError('Order cannot be prepared');
    }

    status = OrderStatus.preparing;
  }

  void ship() {
    if (status != OrderStatus.preparing) {
      throw StateError('Order cannot be shipped');
    }

    status = OrderStatus.shipped;
  }

  void deliver() {
    if (status != OrderStatus.shipped) {
      throw StateError('Order cannot be delivered');
    }

    status = OrderStatus.delivered;
  }

  void cancel() {
    if (status == OrderStatus.delivered) {
      throw StateError('Delivered orders cannot be cancelled');
    }

    status = OrderStatus.cancelled;
  }

  @override
  String toString() {
    return 'Order($id, ${customer.name}, $status, $total)';
  }
}

// ============================================================
// Product Service
// ============================================================

class ProductService {
  final Map<int, Product> _products = {};

  void addProduct(Product product) {
    if (_products.containsKey(product.id)) {
      throw StateError('Product already exists');
    }

    _products[product.id] = product;
  }

  Product? getProduct(int id) {
    return _products[id];
  }

  List<Product> getAllProducts() {
    return _products.values.toList();
  }

  List<Product> getActiveProducts() {
    return _products.values
        .where((product) => product.active)
        .toList();
  }

  List<Product> searchByName(String keyword) {
    return _products.values
        .where(
          (product) => product.name
              .toLowerCase()
              .contains(keyword.toLowerCase()),
        )
        .toList();
  }

  List<Product> searchByCategory(String category) {
    return _products.values
        .where(
          (product) =>
              product.category.toLowerCase() ==
              category.toLowerCase(),
        )
        .toList();
  }

  List<Product> filterByPrice(
    double minPrice,
    double maxPrice,
  ) {
    return _products.values
        .where(
          (product) =>
              product.price >= minPrice &&
              product.price <= maxPrice,
        )
        .toList();
  }

  List<Product> getLowStockProducts(int threshold) {
    return _products.values
        .where((product) => product.stock <= threshold)
        .toList();
  }

  List<Product> getOutOfStockProducts() {
    return _products.values
        .where((product) => product.stock == 0)
        .toList();
  }

  List<Product> sortByPriceAscending() {
    final products = getAllProducts();

    products.sort(
      (a, b) => a.price.compareTo(b.price),
    );

    return products;
  }

  List<Product> sortByPriceDescending() {
    final products = getAllProducts();

    products.sort(
      (a, b) => b.price.compareTo(a.price),
    );

    return products;
  }

  List<Product> sortByName() {
    final products = getAllProducts();

    products.sort(
      (a, b) => a.name.compareTo(b.name),
    );

    return products;
  }

  void updateProductPrice(int id, double price) {
    final product = _products[id];

    if (product == null) {
      throw StateError('Product not found');
    }

    product.updatePrice(price);
  }

  void deleteProduct(int id) {
    if (!_products.containsKey(id)) {
      throw StateError('Product not found');
    }

    _products.remove(id);
  }

  int getProductCount() {
    return _products.length;
  }

  double getAveragePrice() {
    if (_products.isEmpty) {
      return 0;
    }

    final total = _products.values.fold(
      0.0,
      (sum, product) => sum + product.price,
    );

    return total / _products.length;
  }

  Product? getMostExpensiveProduct() {
    if (_products.isEmpty) {
      return null;
    }

    return _products.values.reduce(
      (a, b) => a.price > b.price ? a : b,
    );
  }

  Product? getCheapestProduct() {
    if (_products.isEmpty) {
      return null;
    }

    return _products.values.reduce(
      (a, b) => a.price < b.price ? a : b,
    );
  }
}

// ============================================================
// Customer Service
// ============================================================

class CustomerService {
  final Map<int, Customer> _customers = {};

  void registerCustomer(Customer customer) {
    if (_customers.containsKey(customer.id)) {
      throw StateError('Customer already exists');
    }

    _customers[customer.id] = customer;
  }

  Customer? getCustomer(int id) {
    return _customers[id];
  }

  List<Customer> getAllCustomers() {
    return _customers.values.toList();
  }

  List<Customer> getActiveCustomers() {
    return _customers.values
        .where((customer) => customer.active)
        .toList();
  }

  Customer? findByEmail(String email) {
    for (final customer in _customers.values) {
      if (customer.email == email) {
        return customer;
      }
    }

    return null;
  }

  List<Customer> searchByName(String keyword) {
    return _customers.values
        .where(
          (customer) => customer.name
              .toLowerCase()
              .contains(keyword.toLowerCase()),
        )
        .toList();
  }

  List<Customer> getTopRewardCustomers(int limit) {
    final customers = getAllCustomers();

    customers.sort(
      (a, b) => b.rewardPoints.compareTo(a.rewardPoints),
    );

    return customers.take(limit).toList();
  }

  void addRewardPoints(int customerId, int points) {
    final customer = _customers[customerId];

    if (customer == null) {
      throw StateError('Customer not found');
    }

    customer.addPoints(points);
  }

  void deactivateCustomer(int customerId) {
    final customer = _customers[customerId];

    if (customer == null) {
      throw StateError('Customer not found');
    }

    customer.deactivate();
  }

  int getCustomerCount() {
    return _customers.length;
  }

  int getTotalRewardPoints() {
    return _customers.values.fold(
      0,
      (sum, customer) => sum + customer.rewardPoints,
    );
  }
}

// ============================================================
// Inventory Service
// ============================================================

class InventoryService {
  final ProductService productService;

  InventoryService(this.productService);

  void receiveStock(int productId, int quantity) {
    final product = productService.getProduct(productId);

    if (product == null) {
      throw StateError('Product not found');
    }

    product.addStock(quantity);
  }

  void reduceStock(int productId, int quantity) {
    final product = productService.getProduct(productId);

    if (product == null) {
      throw StateError('Product not found');
    }

    product.removeStock(quantity);
  }

  bool hasEnoughStock(int productId, int quantity) {
    final product = productService.getProduct(productId);

    if (product == null) {
      return false;
    }

    return product.stock >= quantity;
  }

  int getStock(int productId) {
    final product = productService.getProduct(productId);

    if (product == null) {
      return 0;
    }

    return product.stock;
  }

  double getTotalInventoryValue() {
    return productService.getAllProducts().fold(
      0.0,
      (sum, product) => sum + product.inventoryValue,
    );
  }

  int getTotalStockQuantity() {
    return productService.getAllProducts().fold(
      0,
      (sum, product) => sum + product.stock,
    );
  }

  List<Product> getCriticalStockProducts() {
    return productService.getAllProducts()
        .where((product) => product.stock < 5)
        .toList();
  }

  Map<String, int> getStockByCategory() {
    final result = <String, int>{};

    for (final product in productService.getAllProducts()) {
      result[product.category] =
          (result[product.category] ?? 0) + product.stock;
    }

    return result;
  }

  Map<String, double> getInventoryValueByCategory() {
    final result = <String, double>{};

    for (final product in productService.getAllProducts()) {
      result[product.category] =
          (result[product.category] ?? 0) +
          product.inventoryValue;
    }

    return result;
  }
}

// ============================================================
// Discount Service
// ============================================================

class DiscountService {
  double calculatePercentageDiscount(
    double amount,
    double percentage,
  ) {
    if (percentage < 0 || percentage > 100) {
      throw ArgumentError('Invalid percentage');
    }

    return amount * percentage / 100;
  }

  double calculateFixedDiscount(
    double amount,
    double discount,
  ) {
    return min(amount, discount);
  }

  double calculateBulkDiscount(
    double amount,
    int quantity,
  ) {
    if (quantity >= 100) {
      return amount * 0.20;
    }

    if (quantity >= 50) {
      return amount * 0.15;
    }

    if (quantity >= 20) {
      return amount * 0.10;
    }

    if (quantity >= 10) {
      return amount * 0.05;
    }

    return 0;
  }

  double calculateMembershipDiscount(
    double amount,
    int rewardPoints,
  ) {
    if (rewardPoints >= 10000) {
      return amount * 0.15;
    }

    if (rewardPoints >= 5000) {
      return amount * 0.10;
    }

    if (rewardPoints >= 1000) {
      return amount * 0.05;
    }

    return 0;
  }

  double calculateSeasonalDiscount(
    double amount,
    int month,
  ) {
    if (month == 12) {
      return amount * 0.20;
    }

    if (month == 11) {
      return amount * 0.15;
    }

    if (month == 7 || month == 8) {
      return amount * 0.10;
    }

    return 0;
  }

  double calculateFinalPrice(
    double amount,
    double discount,
  ) {
    return max(0, amount - discount);
  }
}

// ============================================================
// Shipping Service
// ============================================================

class ShippingService {
  double calculateShippingFee(double amount) {
    if (amount >= 100000) {
      return 0;
    }

    if (amount >= 50000) {
      return 2500;
    }

    return 5000;
  }

  double calculateExpressShippingFee(double amount) {
    if (amount >= 200000) {
      return 5000;
    }

    return 10000;
  }

  int estimateDeliveryDays(String region) {
    switch (region.toLowerCase()) {
      case 'seoul':
        return 1;

      case 'gyeonggi':
        return 2;

      case 'busan':
        return 3;

      case 'jeju':
        return 5;

      default:
        return 4;
    }
  }

  bool isFreeShipping(double amount) {
    return amount >= 100000;
  }

  String getShippingType(double amount) {
    if (amount >= 100000) {
      return 'FREE';
    }

    if (amount >= 50000) {
      return 'STANDARD';
    }

    return 'BASIC';
  }
}

// ============================================================
// Order Service
// ============================================================

class OrderService {
  final ProductService productService;
  final InventoryService inventoryService;
  final DiscountService discountService;
  final ShippingService shippingService;

  final Map<int, Order> _orders = {};

  int _nextOrderId = 1;

  OrderService({
    required this.productService,
    required this.inventoryService,
    required this.discountService,
    required this.shippingService,
  });

  Order createOrder(
    Customer customer,
    Map<int, int> productQuantities,
  ) {
    if (!customer.active) {
      throw StateError('Customer is inactive');
    }

    if (productQuantities.isEmpty) {
      throw ArgumentError('Order must contain products');
    }

    final items = <OrderItem>[];

    for (final entry in productQuantities.entries) {
      final product = productService.getProduct(entry.key);

      if (product == null) {
        throw StateError('Product not found');
      }

      if (!product.active) {
        throw StateError('Product is inactive');
      }

      if (entry.value <= 0) {
        throw ArgumentError('Invalid quantity');
      }

      if (!inventoryService.hasEnoughStock(
        product.id,
        entry.value,
      )) {
        throw StateError('Insufficient stock');
      }

      items.add(
        OrderItem(
          product: product,
          quantity: entry.value,
          unitPrice: product.price,
        ),
      );
    }

    final order = Order(
      id: _nextOrderId++,
      customer: customer,
      items: items,
      createdAt: DateTime.now(),
    );

    final totalQuantity = order.totalQuantity;

    order.discount = discountService.calculateBulkDiscount(
      order.subtotal,
      totalQuantity,
    );

    order.shippingFee =
        shippingService.calculateShippingFee(
          order.subtotal - order.discount,
        );

    for (final item in items) {
      inventoryService.reduceStock(
        item.product.id,
        item.quantity,
      );
    }

    _orders[order.id] = order;

    return order;
  }

  Order? getOrder(int id) {
    return _orders[id];
  }

  List<Order> getAllOrders() {
    return _orders.values.toList();
  }

  List<Order> getOrdersByCustomer(int customerId) {
    return _orders.values
        .where((order) => order.customer.id == customerId)
        .toList();
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.values
        .where((order) => order.status == status)
        .toList();
  }

  void payOrder(int orderId) {
    final order = _orders[orderId];

    if (order == null) {
      throw StateError('Order not found');
    }

    order.pay();

    final points = (order.total * 0.01).floor();

    order.customer.addPoints(points);
  }

  void prepareOrder(int orderId) {
    final order = _orders[orderId];

    if (order == null) {
      throw StateError('Order not found');
    }

    order.prepare();
  }

  void shipOrder(int orderId) {
    final order = _orders[orderId];

    if (order == null) {
      throw StateError('Order not found');
    }

    order.ship();
  }

  void deliverOrder(int orderId) {
    final order = _orders[orderId];

    if (order == null) {
      throw StateError('Order not found');
    }

    order.deliver();
  }

  void cancelOrder(int orderId) {
    final order = _orders[orderId];

    if (order == null) {
      throw StateError('Order not found');
    }

    order.cancel();

    for (final item in order.items) {
      inventoryService.receiveStock(
        item.product.id,
        item.quantity,
      );
    }
  }

  double getTotalRevenue() {
    return _orders.values
        .where(
          (order) =>
              order.status != OrderStatus.cancelled &&
              order.status != OrderStatus.pending,
        )
        .fold(
          0.0,
          (sum, order) => sum + order.total,
        );
  }

  double getAverageOrderValue() {
    if (_orders.isEmpty) {
      return 0;
    }

    final total = _orders.values.fold(
      0.0,
      (sum, order) => sum + order.total,
    );

    return total / _orders.length;
  }

  int getOrderCount() {
    return _orders.length;
  }

  int getTotalSoldQuantity() {
    return _orders.values
        .where(
          (order) => order.status != OrderStatus.cancelled,
        )
        .fold(
          0,
          (sum, order) => sum + order.totalQuantity,
        );
  }
}

// ============================================================
// Report Service
// ============================================================

class ReportService {
  final ProductService productService;
  final CustomerService customerService;
  final InventoryService inventoryService;
  final OrderService orderService;

  ReportService({
    required this.productService,
    required this.customerService,
    required this.inventoryService,
    required this.orderService,
  });

  void printProductReport() {
    print('====================================');
    print('PRODUCT REPORT');
    print('====================================');

    print('Total Products: ${productService.getProductCount()}');

    print(
      'Average Price: ${productService.getAveragePrice()}',
    );

    print(
      'Most Expensive: '
      '${productService.getMostExpensiveProduct()}',
    );

    print(
      'Cheapest: ${productService.getCheapestProduct()}',
    );

    print('------------------------------------');

    for (final product in productService.getAllProducts()) {
      print(product);
    }
  }

  void printCustomerReport() {
    print('====================================');
    print('CUSTOMER REPORT');
    print('====================================');

    print(
      'Total Customers: ${customerService.getCustomerCount()}',
    );

    print(
      'Total Reward Points: '
      '${customerService.getTotalRewardPoints()}',
    );

    print('------------------------------------');

    for (final customer in customerService.getAllCustomers()) {
      print(customer);
    }
  }

  void printInventoryReport() {
    print('====================================');
    print('INVENTORY REPORT');
    print('====================================');

    print(
      'Total Stock: '
      '${inventoryService.getTotalStockQuantity()}',
    );

    print(
      'Total Inventory Value: '
      '${inventoryService.getTotalInventoryValue()}',
    );

    print('------------------------------------');

    final categoryStock =
        inventoryService.getStockByCategory();

    for (final entry in categoryStock.entries) {
      print('${entry.key}: ${entry.value}');
    }
  }

  void printOrderReport() {
    print('====================================');
    print('ORDER REPORT');
    print('====================================');

    print('Total Orders: ${orderService.getOrderCount()}');

    print('Revenue: ${orderService.getTotalRevenue()}');

    print(
      'Average Order Value: '
      '${orderService.getAverageOrderValue()}',
    );

    print(
      'Total Sold Quantity: '
      '${orderService.getTotalSoldQuantity()}',
    );

    print('------------------------------------');

    for (final order in orderService.getAllOrders()) {
      print(order);
    }
  }

  void printFullReport() {
    printProductReport();
    print('');

    printCustomerReport();
    print('');

    printInventoryReport();
    print('');

    printOrderReport();
  }
}

// ============================================================
// Sample Data
// ============================================================

void initializeProducts(ProductService service) {
  final products = [
    Product(
      id: 1,
      name: 'Laptop',
      category: 'Electronics',
      price: 1500000,
      stock: 20,
    ),
    Product(
      id: 2,
      name: 'Mouse',
      category: 'Electronics',
      price: 30000,
      stock: 100,
    ),
    Product(
      id: 3,
      name: 'Keyboard',
      category: 'Electronics',
      price: 80000,
      stock: 50,
    ),
    Product(
      id: 4,
      name: 'Monitor',
      category: 'Electronics',
      price: 350000,
      stock: 30,
    ),
    Product(
      id: 5,
      name: 'Desk',
      category: 'Furniture',
      price: 250000,
      stock: 15,
    ),
    Product(
      id: 6,
      name: 'Chair',
      category: 'Furniture',
      price: 180000,
      stock: 25,
    ),
    Product(
      id: 7,
      name: 'Notebook',
      category: 'Stationery',
      price: 5000,
      stock: 200,
    ),
    Product(
      id: 8,
      name: 'Pen',
      category: 'Stationery',
      price: 1500,
      stock: 500,
    ),
    Product(
      id: 9,
      name: 'USB Drive',
      category: 'Electronics',
      price: 20000,
      stock: 80,
    ),
    Product(
      id: 10,
      name: 'Headphones',
      category: 'Electronics',
      price: 120000,
      stock: 40,
    ),
  ];

  for (final product in products) {
    service.addProduct(product);
  }
}

void initializeCustomers(CustomerService service) {
  final customers = [
    Customer(
      id: 1,
      name: 'Alice',
      email: 'alice@example.com',
      phone: '010-1111-1111',
      rewardPoints: 1500,
    ),
    Customer(
      id: 2,
      name: 'Bob',
      email: 'bob@example.com',
      phone: '010-2222-2222',
      rewardPoints: 5000,
    ),
    Customer(
      id: 3,
      name: 'Charlie',
      email: 'charlie@example.com',
      phone: '010-3333-3333',
      rewardPoints: 10000,
    ),
    Customer(
      id: 4,
      name: 'David',
      email: 'david@example.com',
      phone: '010-4444-4444',
      rewardPoints: 300,
    ),
    Customer(
      id: 5,
      name: 'Emma',
      email: 'emma@example.com',
      phone: '010-5555-5555',
      rewardPoints: 8000,
    ),
  ];

  for (final customer in customers) {
    service.registerCustomer(customer);
  }
}

// ============================================================
// Application
// ============================================================

void main() {
  print('====================================');
  print('DART SHOPPING MALL APPLICATION');
  print('====================================');
  print('Hello World!');
  print('');

  final productService = ProductService();

  final customerService = CustomerService();

  final inventoryService = InventoryService(
    productService,
  );

  final discountService = DiscountService();

  final shippingService = ShippingService();

  final orderService = OrderService(
    productService: productService,
    inventoryService: inventoryService,
    discountService: discountService,
    shippingService: shippingService,
  );

  final reportService = ReportService(
    productService: productService,
    customerService: customerService,
    inventoryService: inventoryService,
    orderService: orderService,
  );

  initializeProducts(productService);

  initializeCustomers(customerService);

  print('Products initialized.');
  print('Customers initialized.');
  print('');

  final alice = customerService.getCustomer(1)!;
  final bob = customerService.getCustomer(2)!;
  final charlie = customerService.getCustomer(3)!;

  print('Creating sample orders...');
  print('');

  final order1 = orderService.createOrder(
    alice,
    {
      1: 1,
      2: 2,
      3: 1,
    },
  );

  orderService.payOrder(order1.id);
  orderService.prepareOrder(order1.id);
  orderService.shipOrder(order1.id);
  orderService.deliverOrder(order1.id);

  print('Order 1 completed: $order1');

  final order2 = orderService.createOrder(
    bob,
    {
      4: 2,
      6: 2,
      7: 10,
    },
  );

  orderService.payOrder(order2.id);
  orderService.prepareOrder(order2.id);

  print('Order 2 created: $order2');

  final order3 = orderService.createOrder(
    charlie,
    {
      5: 1,
      8: 20,
      9: 5,
    },
  );

  orderService.payOrder(order3.id);

  print('Order 3 created: $order3');

  print('');
  print('Generating reports...');
  print('');

  reportService.printFullReport();

  print('');
  print('====================================');
  print('APPLICATION FINISHED');
  print('====================================');
}

// ============================================================
// SonarQube Security & Code Quality Test
// WARNING: Intentionally insecure examples for testing only
// ============================================================

class SecurityTestService {

  // ----------------------------------------------------------
  // TEST 01 - Hardcoded Password
  // ----------------------------------------------------------

  final String adminUsername = "admin";
  final String adminPassword = "Admin1234!";

  bool authenticate(String username, String password) {
    if (username == adminUsername &&
        password == adminPassword) {
      return true;
    }

    return false;
  }

  // ----------------------------------------------------------
  // TEST 02 - Hardcoded API Token
  // ----------------------------------------------------------

  final String apiToken = "test-api-token-1234567890";

  String getApiToken() {
    return apiToken;
  }

  // ----------------------------------------------------------
  // TEST 03 - Weak Password Validation
  // ----------------------------------------------------------

  bool validatePassword(String password) {
    if (password.length >= 4) {
      return true;
    }

    return false;
  }

  // ----------------------------------------------------------
  // TEST 04 - Sensitive Information Exposure
  // ----------------------------------------------------------

  void printUserCredentials(
    String username,
    String password,
  ) {
    print("Username: $username");
    print("Password: $password");
  }

  // ----------------------------------------------------------
  // TEST 05 - Insecure SQL Query Construction
  // ----------------------------------------------------------

  String buildUserQuery(String username) {
    return "SELECT * FROM users WHERE username = '$username'";
  }

  // ----------------------------------------------------------
  // TEST 06 - Insecure URL
  // ----------------------------------------------------------

  String getApiEndpoint() {
    return "http://example.com/api/login";
  }

  // ----------------------------------------------------------
  // TEST 07 - Weak Random Number Generator
  // ----------------------------------------------------------

  String generateSessionToken() {
    final random = Random();

    return random.nextInt(999999).toString();
  }

  // ----------------------------------------------------------
  // TEST 08 - Empty Catch Block
  // ----------------------------------------------------------

  void processUserData(String data) {
    try {
      int.parse(data);
    } catch (e) {
      // Ignore exception
    }
  }

  // ----------------------------------------------------------
  // TEST 09 - Duplicate Conditions
  // ----------------------------------------------------------

  String checkUserRole(String role) {
    if (role == "admin") {
      return "Administrator";
    } else if (role == "admin") {
      return "System Administrator";
    } else if (role == "user") {
      return "Normal User";
    }

    return "Unknown";
  }

  // ----------------------------------------------------------
  // TEST 10 - Unused Variable
  // ----------------------------------------------------------

  void calculateSecurityScore() {
    int securityScore = 100;
    int unusedSecurityValue = 999;

    securityScore += 10;

    print(securityScore);
  }

  // ----------------------------------------------------------
  // TEST 11 - Always True Condition
  // ----------------------------------------------------------

  bool validateAccess(int userId) {
    if (userId >= 0 || userId < 0) {
      return true;
    }

    return false;
  }

  // ----------------------------------------------------------
  // TEST 12 - Hardcoded Encryption Key
  // ----------------------------------------------------------

  final String encryptionKey = "1234567890123456";

  String getEncryptionKey() {
    return encryptionKey;
  }

  # Test123
}

// ============================================================
// SonarQube Dart Code Quality Test
// Intentionally problematic code for static analysis testing
// ============================================================

class SonarQubeTestService {

  // TEST 01 - Unused Variable
  void unusedVariableTest() {
    int unusedValue = 100;
    int result = 50;

    print(result);
  }

  // TEST 02 - Unreachable Code
  int unreachableCodeTest() {
    return 100;

    print("This code will never execute");
  }

  // TEST 03 - Duplicate Condition
  String duplicateConditionTest(int value) {
    if (value > 10) {
      return "HIGH";
    } else if (value > 10) {
      return "MEDIUM";
    } else {
      return "LOW";
    }
  }

  // TEST 04 - Empty Catch Block
  void emptyCatchTest(String value) {
    try {
      int.parse(value);
    } catch (e) {
    }
  }

  // TEST 05 - Unnecessary Boolean Comparison
  bool booleanComparisonTest(bool isActive) {
    if (isActive == true) {
      return true;
    }

    return false;
  }

  // TEST 06 - Unnecessary Null Check
  String nullCheckTest(String value) {
    if (value == null) {
      return "NULL";
    }

    return value;
  }

  // TEST 07 - Unused Parameter
  void unusedParameterTest(String username, String password) {
    print(username);
  }

  // TEST 08 - Duplicate Code
  int calculatePriceA(int price) {
    int tax = price * 10 ~/ 100;
    int discount = price * 5 ~/ 100;
    int shipping = 3000;

    return price + tax - discount + shipping;
  }

  int calculatePriceB(int price) {
    int tax = price * 10 ~/ 100;
    int discount = price * 5 ~/ 100;
    int shipping = 3000;

    return price + tax - discount + shipping;
  }

  // TEST 09 - Hardcoded Password
  final String adminPassword = "Admin1234!";

  bool authenticate(String password) {
    return password == adminPassword;
  }

  // TEST 10 - Sensitive Information Logging
  void logCredentials(String username, String password) {
    print("Username: $username");
    print("Password: $password");
  }

  // TEST 11 - Insecure HTTP Endpoint
  String getApiUrl() {
    return "http://example.com/api/login";
  }

  // TEST 12 - Weak Random Number Generator
  String generateToken() {
    final random = Random();

    return random.nextInt(999999).toString();
  }
}
