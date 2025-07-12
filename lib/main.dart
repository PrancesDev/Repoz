import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationNotifier(prefs)),
        ChangeNotifierProvider(create: (_) => FavoritesNotifier(prefs)),
        ChangeNotifierProvider(create: (_) => CartNotifier(prefs)),
        ChangeNotifierProvider(create: (_) => InventoryNotifier()),
        ChangeNotifierProvider(create: (_) => OrderNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Italianu\'',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          secondary: Colors.green,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFDA291C),
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Models & Data
// ─────────────────────────────────────────────────────────────────────────────

class Location {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double lat;
  final double lng;

  const Location({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.lat,
    required this.lng,
  });
}

const List<Location> locations = [
  Location(
    id: 'centru',
    name: 'La Italianu\' - Centru',
    address: 'Str. Republicii 15, Cluj-Napoca',
    phone: '+40 264 123 456',
    lat: 46.7712,
    lng: 23.6236,
  ),
  Location(
    id: 'manastur',
    name: 'La Italianu\' - Mănăștur',
    address: 'Str. Mehedinți 45, Cluj-Napoca',
    phone: '+40 264 789 012',
    lat: 46.7833,
    lng: 23.5667,
  ),
  Location(
    id: 'floresti',
    name: 'La Italianu\' - Florești',
    address: 'Str. Florilor 12, Florești',
    phone: '+40 264 345 678',
    lat: 46.7500,
    lng: 23.5000,
  ),
];

enum MenuCategory { pizza, pasta, desserts, drinks }

class MenuItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> tags;
  final List<String> sizes;
  final List<double> prices;
  final MenuCategory category;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.tags,
    required this.sizes,
    required this.prices,
    required this.category,
  });
}

// Sample menu data
const List<MenuItem> menuItems = [
  // Pizzas
  MenuItem(
    id: 'pepperoni',
    name: 'Pepperoni',
    description: 'Salam picant cu mozzarella și oregano.',
    imageUrl: 'assets/images/pepperoni.png',
    tags: ['picant', 'cu carne'],
    sizes: ['Mică', 'Medie', 'Mare'],
    prices: [26.99, 31.99, 36.99],
    category: MenuCategory.pizza,
  ),
  MenuItem(
    id: 'margherita',
    name: 'Margherita',
    description: 'Clasică cu sos de roșii, mozzarella și busuioc proaspăt.',
    imageUrl: 'assets/images/margherita.png',
    tags: ['vegetariană'],
    sizes: ['Mică', 'Medie', 'Mare'],
    prices: [24.99, 29.99, 34.99],
    category: MenuCategory.pizza,
  ),
  MenuItem(
    id: 'quattro_formaggi',
    name: 'Quattro Formaggi',
    description: 'Patru brânzeturi: mozzarella, gorgonzola, parmesan și fontina.',
    imageUrl: 'assets/images/quattro_formaggi.png',
    tags: ['vegetariană', 'cu lactoză'],
    sizes: ['Mică', 'Medie', 'Mare'],
    prices: [27.49, 32.49, 37.49],
    category: MenuCategory.pizza,
  ),
  
  // Pasta
  MenuItem(
    id: 'carbonara',
    name: 'Spaghetti Carbonara',
    description: 'Paste cu bacon, ou, parmezan și piper negru.',
    imageUrl: 'assets/images/carbonara.png',
    tags: ['cu carne', 'cu lactoză'],
    sizes: ['Porție'],
    prices: [28.99],
    category: MenuCategory.pasta,
  ),
  MenuItem(
    id: 'bolognese',
    name: 'Tagliatelle Bolognese',
    description: 'Paste cu sos de carne tradițional italian.',
    imageUrl: 'assets/images/bolognese.png',
    tags: ['cu carne'],
    sizes: ['Porție'],
    prices: [32.99],
    category: MenuCategory.pasta,
  ),
  MenuItem(
    id: 'pesto',
    name: 'Penne Pesto',
    description: 'Paste cu sos de busuioc, usturoi și parmezan.',
    imageUrl: 'assets/images/pesto.png',
    tags: ['vegetariană'],
    sizes: ['Porție'],
    prices: [26.99],
    category: MenuCategory.pasta,
  ),

  // Desserts
  MenuItem(
    id: 'tiramisu',
    name: 'Tiramisu',
    description: 'Desert italian clasic cu mascarpone și cafea.',
    imageUrl: 'assets/images/tiramisu.png',
    tags: ['dulce', 'cu lactoză'],
    sizes: ['Porție'],
    prices: [18.99],
    category: MenuCategory.desserts,
  ),
  MenuItem(
    id: 'panna_cotta',
    name: 'Panna Cotta',
    description: 'Desert cremos cu fructe de pădure.',
    imageUrl: 'assets/images/panna_cotta.png',
    tags: ['dulce', 'cu lactoză'],
    sizes: ['Porție'],
    prices: [16.99],
    category: MenuCategory.desserts,
  ),

  // Drinks
  MenuItem(
    id: 'coca_cola',
    name: 'Coca Cola',
    description: 'Băutură răcoritoare carbogazoasă.',
    imageUrl: 'assets/images/coca_cola.png',
    tags: ['răcoritoare'],
    sizes: ['330ml', '500ml'],
    prices: [8.99, 12.99],
    category: MenuCategory.drinks,
  ),
  MenuItem(
    id: 'wine_red',
    name: 'Vin Roșu Casa',
    description: 'Vin roșu de casă, sec.',
    imageUrl: 'assets/images/wine_red.png',
    tags: ['alcool'],
    sizes: ['Pahar', 'Sticlă'],
    prices: [15.99, 89.99],
    category: MenuCategory.drinks,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Splash Screen
// ─────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LocationSelectionScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDA291C),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(75),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_pizza,
                        size: 80,
                        color: Color(0xFFDA291C),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'La Italianu\'',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Authentic Italian Cuisine',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 50),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Location Selection Screen
// ─────────────────────────────────────────────────────────────────────────────

class LocationSelectionScreen extends StatelessWidget {
  const LocationSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDA291C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Alegeți locația',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Selectați restaurantul cel mai apropiat',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final location = locations[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            context.read<LocationNotifier>().setLocation(location.id);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDA291C).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Color(0xFFDA291C),
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        location.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        location.address,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        location.phone,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFFDA291C),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifiers
// ─────────────────────────────────────────────────────────────────────────────

class LocationNotifier extends ChangeNotifier {
  static const _key = 'selected_location';
  final SharedPreferences _prefs;
  String _selectedLocationId = '';

  LocationNotifier(this._prefs) {
    _selectedLocationId = _prefs.getString(_key) ?? '';
  }

  String get selectedLocationId => _selectedLocationId;
  
  Location? get selectedLocation {
    if (_selectedLocationId.isEmpty) return null;
    return locations.firstWhere(
      (loc) => loc.id == _selectedLocationId,
      orElse: () => locations.first,
    );
  }

  void setLocation(String locationId) {
    _selectedLocationId = locationId;
    _prefs.setString(_key, locationId);
    notifyListeners();
  }
}

class InventoryNotifier extends ChangeNotifier {
  // Simulated inventory - in real app this would come from Firebase
  final Map<String, Map<String, bool>> _inventory = {
    'centru': {
      'pepperoni': true,
      'margherita': true,
      'quattro_formaggi': false, // Out of stock in center
      'carbonara': true,
      'bolognese': true,
      'pesto': true,
      'tiramisu': true,
      'panna_cotta': false,
      'coca_cola': true,
      'wine_red': true,
    },
    'manastur': {
      'pepperoni': true,
      'margherita': true,
      'quattro_formaggi': true,
      'carbonara': false, // Out of stock in Manastur
      'bolognese': true,
      'pesto': true,
      'tiramisu': true,
      'panna_cotta': true,
      'coca_cola': true,
      'wine_red': false,
    },
    'floresti': {
      'pepperoni': true,
      'margherita': true,
      'quattro_formaggi': true,
      'carbonara': true,
      'bolognese': true,
      'pesto': false, // Out of stock in Floresti
      'tiramisu': false,
      'panna_cotta': true,
      'coca_cola': true,
      'wine_red': true,
    },
  };

  bool isAvailable(String itemId, String locationId) {
    return _inventory[locationId]?[itemId] ?? false;
  }

  void toggleAvailability(String itemId, String locationId) {
    if (_inventory[locationId] != null) {
      _inventory[locationId]![itemId] = !(_inventory[locationId]![itemId] ?? false);
      notifyListeners();
    }
  }
}

class FavoritesNotifier extends ChangeNotifier {
  static const _key = 'favorites';
  final SharedPreferences _prefs;
  Set<String> _favs;

  FavoritesNotifier(this._prefs)
      : _favs = (_prefs.getStringList(_key)?.toSet() ?? <String>{});

  Set<String> get favorites => _favs;
  bool isFavorite(String id) => _favs.contains(id);

  void toggle(String id) {
    if (_favs.contains(id)) {
      _favs.remove(id);
    } else {
      _favs.add(id);
    }
    _prefs.setStringList(_key, _favs.toList());
    notifyListeners();
  }
}

class CartItem {
  final String itemId;
  final String name;
  final String size;
  final double price;
  final String locationId;
  int quantity;

  CartItem({
    required this.itemId,
    required this.name,
    required this.size,
    required this.price,
    required this.locationId,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'name': name,
    'size': size,
    'price': price,
    'locationId': locationId,
    'quantity': quantity,
  };

  static CartItem fromJson(Map<String, dynamic> j) => CartItem(
    itemId: j['itemId'] ?? '',
    name: j['name'],
    size: j['size'],
    price: (j['price'] as num).toDouble(),
    locationId: j['locationId'] ?? '',
    quantity: j['quantity'] as int? ?? 1,
  );
}

class CartNotifier extends ChangeNotifier {
  static const _key = 'cart';
  final SharedPreferences _prefs;
  List<CartItem> _items = [];

  CartNotifier(this._prefs) {
    final saved = _prefs.getStringList(_key);
    if (saved != null) {
      _items = saved
          .map((e) => CartItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();
    }
  }

  List<CartItem> get items => _items;
  double get total => _items.fold(0, (sum, i) => sum + i.price * i.quantity);

  void _save() {
    _prefs.setStringList(
      _key,
      _items.map((i) => jsonEncode(i.toJson())).toList(),
    );
  }

  void add(CartItem item) {
    final existing = _items.firstWhere(
      (i) => i.itemId == item.itemId && i.size == item.size && i.locationId == item.locationId,
      orElse: () => CartItem(itemId: '', name: '', size: '', price: 0, locationId: ''),
    );
    
    if (existing.itemId.isNotEmpty) {
      existing.quantity += item.quantity;
    } else {
      _items.add(item);
    }
    _save();
    notifyListeners();
  }

  void increment(int idx) {
    if (_items[idx].quantity < 999) _items[idx].quantity++;
    _save();
    notifyListeners();
  }

  void decrement(int idx) {
    final it = _items[idx];
    if (it.quantity > 1) {
      it.quantity--;
    } else {
      _items.removeAt(idx);
    }
    _save();
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    _save();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _save();
    notifyListeners();
  }
}

class OrderNotifier extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> submitOrder(List<CartItem> items, String locationId, String? userId) async {
    try {
      final order = {
        'items': items.map((item) => item.toJson()).toList(),
        'locationId': locationId,
        'userId': userId,
        'total': items.fold(0.0, (sum, item) => sum + item.price * item.quantity),
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'estimatedTime': 30, // minutes
      };
      
      await _firestore.collection('orders').add(order);
    } catch (e) {
      print('Error submitting order: $e');
      rethrow;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen & Bottom Navigation
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const MenuCategoriesPage(),
    const FavoritesPage(),
    const AccountPage(),
  ];

  void _onTap(int i) => setState(() => _currentIndex = i);

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartNotifier>().items.fold<int>(
      0, (sum, i) => sum + i.quantity,
    );
    final location = context.watch<LocationNotifier>().selectedLocation;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("La Italianu'"),
            if (location != null)
              Text(
                location.name.split(' - ').last,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationSelectionScreen()),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartPage()),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.shopping_cart),
            if (cartCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.white,
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(fontSize: 10, color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTap,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Acasă'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Meniu'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cont'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HomePage with Menu Categories
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationNotifier>().selectedLocation;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (location != null) ...[
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comandă de la:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          location.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          location.address,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        Text(
          'Meniul nostru',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Menu Categories Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCategoryCard(
              context,
              'Pizza',
              Icons.local_pizza,
              Colors.red,
              MenuCategory.pizza,
            ),
            _buildCategoryCard(
              context,
              'Paste',
              Icons.ramen_dining,
              Colors.orange,
              MenuCategory.pasta,
            ),
            _buildCategoryCard(
              context,
              'Deserturi',
              Icons.cake,
              Colors.pink,
              MenuCategory.desserts,
            ),
            _buildCategoryCard(
              context,
              'Băuturi',
              Icons.local_drink,
              Colors.blue,
              MenuCategory.drinks,
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Recomandate',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        
        // Featured items
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              final item = menuItems.where((item) => item.category == MenuCategory.pizza).take(3).toList()[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: _buildFeaturedItemCard(context, item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    MenuCategory category,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryMenuPage(category: category),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedItemCard(BuildContext context, MenuItem item) {
    final inventory = context.watch<InventoryNotifier>();
    final location = context.watch<LocationNotifier>().selectedLocationId;
    final isAvailable = inventory.isAvailable(item.id, location);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isAvailable ? () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailPage(item: item)),
          );
        } : null,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      color: Colors.grey[100],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_pizza,
                        size: 60,
                        color: isAvailable ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? Colors.black : Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.prices.first.toStringAsFixed(2)} Lei',
                        style: TextStyle(
                          color: isAvailable ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isAvailable)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: const Center(
                    child: Text(
                      'INDISPONIBIL',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Menu Categories Page
// ─────────────────────────────────────────────────────────────────────────────

class MenuCategoriesPage extends StatelessWidget {
  const MenuCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Categorii Meniu',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        
        _buildCategoryTile(
          context,
          'Pizza',
          'Pizze tradiționale italiene',
          Icons.local_pizza,
          Colors.red,
          MenuCategory.pizza,
        ),
        _buildCategoryTile(
          context,
          'Paste',
          'Paste proaspete cu sosuri delicioase',
          Icons.ramen_dining,
          Colors.orange,
          MenuCategory.pasta,
        ),
        _buildCategoryTile(
          context,
          'Deserturi',
          'Dulciuri italiene autentice',
          Icons.cake,
          Colors.pink,
          MenuCategory.desserts,
        ),
        _buildCategoryTile(
          context,
          'Băuturi',
          'Băuturi răcoritoare și vinuri',
          Icons.local_drink,
          Colors.blue,
          MenuCategory.drinks,
        ),
      ],
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    MenuCategory category,
  ) {
    final itemCount = menuItems.where((item) => item.category == category).length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryMenuPage(category: category),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$itemCount produse',
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Menu Page
// ─────────────────────────────────────────────────────────────────────────────

class CategoryMenuPage extends StatelessWidget {
  final MenuCategory category;
  
  const CategoryMenuPage({super.key, required this.category});

  String get categoryTitle {
    switch (category) {
      case MenuCategory.pizza:
        return 'Pizza';
      case MenuCategory.pasta:
        return 'Paste';
      case MenuCategory.desserts:
        return 'Deserturi';
      case MenuCategory.drinks:
        return 'Băuturi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryItems = menuItems.where((item) => item.category == category).toList();
    final favs = context.watch<FavoritesNotifier>();
    final inventory = context.watch<InventoryNotifier>();
    final location = context.watch<LocationNotifier>().selectedLocationId;

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categoryItems.length,
        itemBuilder: (ctx, i) {
          final item = categoryItems[i];
          final isAvailable = inventory.isAvailable(item.id, location);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isAvailable ? () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailPage(item: item)),
                ) : null,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getCategoryIcon(),
                              size: 40,
                              color: isAvailable ? Colors.red : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable ? Colors.black : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isAvailable ? Colors.grey[600] : Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${item.prices.first.toStringAsFixed(2)} Lei',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              favs.isFavorite(item.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: favs.isFavorite(item.id)
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () => favs.toggle(item.id),
                          ),
                        ],
                      ),
                    ),
                    if (!isAvailable)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withOpacity(0.6),
                          ),
                          child: const Center(
                            child: Text(
                              'INDISPONIBIL',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (category) {
      case MenuCategory.pizza:
        return Icons.local_pizza;
      case MenuCategory.pasta:
        return Icons.ramen_dining;
      case MenuCategory.desserts:
        return Icons.cake;
      case MenuCategory.drinks:
        return Icons.local_drink;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FavoritesPage
// ─────────────────────────────────────────────────────────────────────────────

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesNotifier>();
    final favList = menuItems.where((item) => favs.isFavorite(item.id)).toList();
    final inventory = context.watch<InventoryNotifier>();
    final location = context.watch<LocationNotifier>().selectedLocationId;

    if (favList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nu aveți favorite',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favList.length,
      itemBuilder: (ctx, i) {
        final item = favList[i];
        final isAvailable = inventory.isAvailable(item.id, location);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getItemIcon(item.category),
                  color: isAvailable ? Colors.red : Colors.grey,
                ),
              ),
              title: Text(
                item.name,
                style: TextStyle(
                  color: isAvailable ? Colors.black : Colors.grey,
                ),
              ),
              subtitle: Text(
                '${item.prices.first.toStringAsFixed(2)} Lei',
                style: TextStyle(
                  color: isAvailable ? Colors.red : Colors.grey,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.green),
                onPressed: () => favs.toggle(item.id),
              ),
              onTap: isAvailable ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailPage(item: item)),
              ) : null,
            ),
          ),
        );
      },
    );
  }

  IconData _getItemIcon(MenuCategory category) {
    switch (category) {
      case MenuCategory.pizza:
        return Icons.local_pizza;
      case MenuCategory.pasta:
        return Icons.ramen_dining;
      case MenuCategory.desserts:
        return Icons.cake;
      case MenuCategory.drinks:
        return Icons.local_drink;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DetailPage
// ─────────────────────────────────────────────────────────────────────────────

class DetailPage extends StatefulWidget {
  final MenuItem item;
  const DetailPage({super.key, required this.item});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _selected = 0;
  int _quantity = 1;

  void _orderNow() {
    final cart = context.read<CartNotifier>();
    final location = context.read<LocationNotifier>().selectedLocationId;
    
    cart.add(CartItem(
      itemId: widget.item.id,
      name: widget.item.name,
      size: widget.item.sizes[_selected],
      price: widget.item.prices[_selected],
      locationId: location,
      quantity: _quantity,
    ));
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final inventory = context.watch<InventoryNotifier>();
    final location = context.watch<LocationNotifier>().selectedLocationId;
    final isAvailable = inventory.isAvailable(item.id, location);

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        _getItemIcon(item.category),
                        size: 100,
                        color: isAvailable ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      if (!isAvailable)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Indisponibil',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            if (isAvailable) ...[
              Text(
                'Alege mărimea:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(item.sizes.length, (i) {
                  return ChoiceChip(
                    label: Text(
                      '${item.sizes[i]} (${item.prices[i].toStringAsFixed(2)} Lei)',
                    ),
                    selected: _selected == i,
                    onSelected: (_) => setState(() => _selected = i),
                    selectedColor: Colors.green.shade200,
                  );
                }),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Cantitate:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: isAvailable ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.shopping_cart),
            label: Text(
              'Adaugă în coș (${(_quantity * item.prices[_selected]).toStringAsFixed(2)} Lei)',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _orderNow,
          ),
        ),
      ) : null,
    );
  }

  IconData _getItemIcon(MenuCategory category) {
    switch (category) {
      case MenuCategory.pizza:
        return Icons.local_pizza;
      case MenuCategory.pasta:
        return Icons.ramen_dining;
      case MenuCategory.desserts:
        return Icons.cake;
      case MenuCategory.drinks:
        return Icons.local_drink;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CartPage
// ─────────────────────────────────────────────────────────────────────────────

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartNotifier>();
    final orderNotifier = context.read<OrderNotifier>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Coșul tău')),
      body: cart.items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Coșul este gol',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final item = cart.items[i];
                return Dismissible(
                  key: ValueKey('$i${item.itemId}${item.size}'),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => cart.removeAt(i),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${item.name} (${item.size})'),
                      subtitle: Text(
                        '${(item.price * item.quantity).toStringAsFixed(2)} Lei',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => cart.decrement(i),
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => cart.increment(i),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.items.isNotEmpty ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Finalizează comanda (${cart.total.toStringAsFixed(2)} Lei)',
            ),
            onPressed: () async {
              try {
                final location = context.read<LocationNotifier>().selectedLocationId;
                await orderNotifier.submitOrder(cart.items, location, user?.uid);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comanda a fost trimisă cu succes!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  cart.clear();
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Eroare la trimiterea comenzii: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ),
      ) : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Account Page
// ─────────────────────────────────────────────────────────────────────────────

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with AutomaticKeepAliveClientMixin {
  User? _user;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((u) {
      setState(() => _user = u);
    });
  }

  Future<void> _signOut() async => FirebaseAuth.instance.signOut();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Conectați-vă pentru a accesa contul',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignInPage()),
              ),
              child: const Text('Autentificare'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpPage()),
              ),
              child: const Text('Înregistrare'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Autentificat ca:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  _user!.email ?? '',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Istoric comenzi'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to order history
          },
        ),
        
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('Schimbă locația'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LocationSelectionScreen()),
            );
          },
        ),
        
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Setări'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to settings
          },
        ),
        
        const Divider(height: 32),
        
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            'Ieșire din cont',
            style: TextStyle(color: Colors.red),
          ),
          onTap: _signOut,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Authentication Pages
// ─────────────────────────────────────────────────────────────────────────────

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _error = '';
  bool _loading = false;

  Future<void> _submit() async {
    setState(() {
      _error = '';
      _loading = true;
    });
    
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _loading = false);
      return;
    }
    
    _formKey.currentState!.save();
    
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Autentificare eșuată: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Autentificare')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onSaved: (v) => _email = v!.trim(),
                validator: (v) => (v?.contains('@') ?? false)
                    ? null
                    : 'Email invalid',
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Parolă',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onSaved: (v) => _password = v!.trim(),
                validator: (v) => (v != null && v.length >= 6)
                    ? null
                    : 'Minim 6 caractere',
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Autentificare'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirm = '';
  String _error = '';
  bool _loading = false;

  Future<void> _submit() async {
    setState(() {
      _error = '';
      _loading = true;
    });
    
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _loading = false);
      return;
    }
    
    _formKey.currentState!.save();
    
    if (_password != _confirm) {
      setState(() {
        _error = 'Parolele nu coincid';
        _loading = false;
      });
      return;
    }
    
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cont creat cu succes!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = 'Înregistrare eșuată: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Înregistrare')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onSaved: (v) => _email = v!.trim(),
                validator: (v) => (v?.contains('@') ?? false)
                    ? null
                    : 'Email invalid',
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Parolă',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onSaved: (v) => _password = v!.trim(),
                validator: (v) => (v != null && v.length >= 6)
                    ? null
                    : 'Minim 6 caractere',
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Confirmă parola',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onSaved: (v) => _confirm = v!.trim(),
                validator: (v) => (v != null && v.length >= 6)
                    ? null
                    : 'Minim 6 caractere',
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Înregistrare'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}