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
// Models & Notifiers
// ─────────────────────────────────────────────────────────────────────────────

class Location {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const Location({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

const List<Location> locations = [
  Location(
    id: 'centru',
    name: 'Centru',
    address: 'Str. Republicii 15, Cluj-Napoca',
    latitude: 46.7712,
    longitude: 23.6236,
  ),
  Location(
    id: 'manastur',
    name: 'Mănăștur',
    address: 'Str. Mehedinți 45, Cluj-Napoca',
    latitude: 46.7833,
    longitude: 23.5667,
  ),
  Location(
    id: 'floresti',
    name: 'Florești',
    address: 'Str. Florilor 12, Florești',
    latitude: 46.7500,
    longitude: 23.5000,
  ),
];

class LocationNotifier extends ChangeNotifier {
  static const _key = 'selected_location';
  final SharedPreferences _prefs;
  String? _selectedLocationId;

  LocationNotifier(this._prefs) {
    _selectedLocationId = _prefs.getString(_key);
  }

  String? get selectedLocationId => _selectedLocationId;
  
  Location? get selectedLocation {
    if (_selectedLocationId == null) return null;
    return locations.firstWhere((loc) => loc.id == _selectedLocationId);
  }

  void selectLocation(String locationId) {
    _selectedLocationId = locationId;
    _prefs.setString(_key, locationId);
    notifyListeners();
  }
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final List<String> tags;
  final List<String> sizes;
  final List<double> prices;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.tags,
    required this.sizes,
    required this.prices,
  });
}

class MenuCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const MenuCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const List<MenuCategory> menuCategories = [
  MenuCategory(
    id: 'pizza',
    name: 'Pizza',
    description: 'Pizza tradițională italiană',
    icon: Icons.local_pizza,
    color: Colors.red,
  ),
  MenuCategory(
    id: 'pasta',
    name: 'Paste',
    description: 'Paste proaspete cu sosuri delicioase',
    icon: Icons.ramen_dining,
    color: Colors.orange,
  ),
  MenuCategory(
    id: 'desserts',
    name: 'Deserturi',
    description: 'Dulciuri italiene autentice',
    icon: Icons.cake,
    color: Colors.pink,
  ),
  MenuCategory(
    id: 'drinks',
    name: 'Băuturi',
    description: 'Băuturi răcoritoare și vinuri',
    icon: Icons.local_bar,
    color: Colors.blue,
  ),
];

const List<MenuItem> menuItems = [
  // Pizza
  MenuItem(
    id: 'pepperoni',
    name: 'Pepperoni',
    description: 'Salam picant cu mozzarella și oregano.',
    imageUrl: 'assets/images/pepperoni.png',
    category: 'pizza',
    tags: ['picant', 'cu carne'],
    sizes: ['Mică', 'Medie', 'Mare'],
    prices: [26.99, 31.99, 36.99],
  ),
  MenuItem(
    id: 'margherita',
    name: 'Margherita',
    description: 'Clasică cu sos de roșii, mozzarella și busuioc proaspăt.',
    imageUrl: 'assets/images/margherita.png',
    category: 'pizza',
    tags: ['vegetariană'],
    sizes: ['Mică', 'Medie', 'Mare'],
    prices: [24.99, 29.99, 34.99],
  ),
  MenuItem(
    id: 'quattro_formaggi',
    name: 'Quattro Formaggi',
    description: 'Patru brânzeturi: mozzarella, gorgonzola, parmesan și fontina.',
    imageUrl: 'assets/images/quattro_formaggi.png',
    category: 'pizza',
    tags: ['vegetariană', 'cu lactoză'],
    sizes: ['Mică', 'Medie', 'Mare'],
    prices: [27.49, 32.49, 37.49],
  ),
  MenuItem(
    id: 'prosciutto_funghi',
    name: 'Prosciutto e Funghi',
    description: 'Șuncă de Parma și ciuperci champignon cu mozzarella.',
    imageUrl: 'assets/images/prosciutto_funghi.png',
    category: 'pizza',
    tags: ['cu carne'],
    sizes: ['Mică', 'Medie', 'Mare'],
    prices: [25.99, 30.99, 35.99],
  ),
  
  // Pasta
  MenuItem(
    id: 'carbonara',
    name: 'Spaghetti Carbonara',
    description: 'Spaghetti cu bacon, ou, parmezan și piper negru.',
    imageUrl: 'assets/images/carbonara.png',
    category: 'pasta',
    tags: ['cu carne', 'cu lactoză'],
    sizes: ['Porție'],
    prices: [28.99],
  ),
  MenuItem(
    id: 'bolognese',
    name: 'Tagliatelle Bolognese',
    description: 'Tagliatelle cu sos de carne tradițional bolognese.',
    imageUrl: 'assets/images/bolognese.png',
    category: 'pasta',
    tags: ['cu carne'],
    sizes: ['Porție'],
    prices: [29.99],
  ),
  MenuItem(
    id: 'pesto',
    name: 'Penne Pesto',
    description: 'Penne cu sos pesto din busuioc proaspăt și parmigiano.',
    imageUrl: 'assets/images/pesto.png',
    category: 'pasta',
    tags: ['vegetariană'],
    sizes: ['Porție'],
    prices: [26.99],
  ),
  
  // Desserts
  MenuItem(
    id: 'tiramisu',
    name: 'Tiramisu',
    description: 'Desert clasic italian cu mascarpone și cafea.',
    imageUrl: 'assets/images/tiramisu.png',
    category: 'desserts',
    tags: ['cu lactoză', 'cu cafeină'],
    sizes: ['Porție'],
    prices: [18.99],
  ),
  MenuItem(
    id: 'panna_cotta',
    name: 'Panna Cotta',
    description: 'Desert cremos cu fructe de pădure.',
    imageUrl: 'assets/images/panna_cotta.png',
    category: 'desserts',
    tags: ['cu lactoză'],
    sizes: ['Porție'],
    prices: [16.99],
  ),
  
  // Drinks
  MenuItem(
    id: 'coca_cola',
    name: 'Coca Cola',
    description: 'Băutură răcoritoare carbogazoasă.',
    imageUrl: 'assets/images/coca_cola.png',
    category: 'drinks',
    tags: ['răcoritoare'],
    sizes: ['330ml', '500ml'],
    prices: [8.99, 12.99],
  ),
  MenuItem(
    id: 'wine_red',
    name: 'Vin Roșu Casa',
    description: 'Vin roșu de casă, selecție italiană.',
    imageUrl: 'assets/images/wine_red.png',
    category: 'drinks',
    tags: ['alcool'],
    sizes: ['Pahar', 'Sticlă'],
    prices: [15.99, 89.99],
  ),
];

class InventoryNotifier extends ChangeNotifier {
  // Simulated inventory - in real app this would be from Firebase
  Map<String, Map<String, bool>> _inventory = {
    'centru': {
      'pepperoni': true,
      'margherita': true,
      'quattro_formaggi': false, // Out of stock
      'prosciutto_funghi': true,
      'carbonara': true,
      'bolognese': true,
      'pesto': true,
      'tiramisu': true,
      'panna_cotta': false, // Out of stock
      'coca_cola': true,
      'wine_red': true,
    },
    'manastur': {
      'pepperoni': true,
      'margherita': true,
      'quattro_formaggi': true,
      'prosciutto_funghi': true,
      'carbonara': false, // Out of stock
      'bolognese': true,
      'pesto': true,
      'tiramisu': true,
      'panna_cotta': true,
      'coca_cola': true,
      'wine_red': false, // Out of stock
    },
    'floresti': {
      'pepperoni': true,
      'margherita': true,
      'quattro_formaggi': true,
      'prosciutto_funghi': true,
      'carbonara': true,
      'bolognese': true,
      'pesto': false, // Out of stock
      'tiramisu': false, // Out of stock
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
    itemId: j['itemId'],
    name: j['name'],
    size: j['size'],
    price: (j['price'] as num).toDouble(),
    locationId: j['locationId'],
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

// ─────────────────────────────────────────────────────────────────────────────
// Location Selection Screen
// ─────────────────────────────────────────────────────────────────────────────

class LocationSelectionScreen extends StatelessWidget {
  const LocationSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Alege Locația'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selectează restaurantul cel mai apropiat:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          context.read<LocationNotifier>().selectLocation(location.id);
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
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: Theme.of(context).primaryColor,
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
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey[400],
                                size: 16,
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
    );
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
    const MenuPage(),
    const FavoritesPage(),
    const AccountPage(),
  ];

  void _onTap(int i) => setState(() => _currentIndex = i);

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartNotifier>().items.fold<int>(
      0,
      (sum, i) => sum + i.quantity,
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
                location.name,
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
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Meniu'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cont'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HomePage with Categories
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationNotifier>().selectedLocation;
    final inventory = context.watch<InventoryNotifier>();
    
    // Get featured items (available items from different categories)
    final featuredItems = menuItems.where((item) {
      return location != null && inventory.isAvailable(item.id, location.id);
    }).take(5).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bun venit la La Italianu\'!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Descoperă aromele autentice ale Italiei',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Categories section
        const Text(
          'Categorii Meniu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: menuCategories.length,
          itemBuilder: (context, index) {
            final category = menuCategories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryPage(category: category),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      category.color.withOpacity(0.7),
                      category.color,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: category.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.icon,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 32),
        
        // Featured items section
        if (featuredItems.isNotEmpty) ...[
          const Text(
            'Recomandări',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: featuredItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final item = featuredItems[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(item: item),
                      ),
                    );
                  },
                  child: Container(
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(item.category),
                              size: 48,
                              color: Colors.grey[400],
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
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.prices[0].toStringAsFixed(2)} Lei',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'pizza':
        return Icons.local_pizza;
      case 'pasta':
        return Icons.ramen_dining;
      case 'desserts':
        return Icons.cake;
      case 'drinks':
        return Icons.local_bar;
      default:
        return Icons.restaurant;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Page
// ─────────────────────────────────────────────────────────────────────────────

class CategoryPage extends StatelessWidget {
  final MenuCategory category;
  
  const CategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationNotifier>().selectedLocation;
    final inventory = context.watch<InventoryNotifier>();
    final favs = context.watch<FavoritesNotifier>();
    
    final categoryItems = menuItems.where((item) => item.category == category.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: category.color,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categoryItems.length,
        itemBuilder: (context, index) {
          final item = categoryItems[index];
          final isAvailable = location != null && inventory.isAvailable(item.id, location.id);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: isAvailable ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(item: item),
                        ),
                      );
                    } : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                _getCategoryIcon(item.category),
                                size: 40,
                                color: isAvailable ? category.color : Colors.grey,
                              ),
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
                                    color: isAvailable ? Colors.black87 : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isAvailable ? Colors.grey[600] : Colors.grey[400],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isAvailable 
                                    ? '${item.prices[0].toStringAsFixed(2)} Lei'
                                    : 'INDISPONIBIL',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable ? Colors.red[600] : Colors.red[300],
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
                  ),
                  if (!isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'INDISPONIBIL',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'pizza':
        return Icons.local_pizza;
      case 'pasta':
        return Icons.ramen_dining;
      case 'desserts':
        return Icons.cake;
      case 'drinks':
        return Icons.local_bar;
      default:
        return Icons.restaurant;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MenuPage (All Items)
// ─────────────────────────────────────────────────────────────────────────────

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationNotifier>().selectedLocation;
    final inventory = context.watch<InventoryNotifier>();
    final favs = context.watch<FavoritesNotifier>();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final isAvailable = location != null && inventory.isAvailable(item.id, location.id);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isAvailable ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(item: item),
                      ),
                    );
                  } : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(item.category),
                              size: 40,
                              color: isAvailable ? _getCategoryColor(item.category) : Colors.grey,
                            ),
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
                                  color: isAvailable ? Colors.black87 : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isAvailable ? Colors.grey[600] : Colors.grey[400],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isAvailable 
                                  ? '${item.prices[0].toStringAsFixed(2)} Lei'
                                  : 'INDISPONIBIL',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isAvailable ? Colors.red[600] : Colors.red[300],
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
                ),
                if (!isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'INDISPONIBIL',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'pizza':
        return Icons.local_pizza;
      case 'pasta':
        return Icons.ramen_dining;
      case 'desserts':
        return Icons.cake;
      case 'drinks':
        return Icons.local_bar;
      default:
        return Icons.restaurant;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'pizza':
        return Colors.red;
      case 'pasta':
        return Colors.orange;
      case 'desserts':
        return Colors.pink;
      case 'drinks':
        return Colors.blue;
      default:
        return Colors.grey;
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
    final location = context.watch<LocationNotifier>().selectedLocation;
    final inventory = context.watch<InventoryNotifier>();
    
    final favList = menuItems.where((item) => favs.isFavorite(item.id)).toList();

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
      itemBuilder: (context, index) {
        final item = favList[index];
        final isAvailable = location != null && inventory.isAvailable(item.id, location.id);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isAvailable ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(item: item),
                  ),
                );
              } : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(item.category),
                          size: 30,
                          color: isAvailable ? _getCategoryColor(item.category) : Colors.grey,
                        ),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isAvailable ? Colors.black87 : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAvailable 
                              ? '${item.prices[0].toStringAsFixed(2)} Lei'
                              : 'INDISPONIBIL',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isAvailable ? Colors.red[600] : Colors.red[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.green,
                      onPressed: () => favs.toggle(item.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'pizza':
        return Icons.local_pizza;
      case 'pasta':
        return Icons.ramen_dining;
      case 'desserts':
        return Icons.cake;
      case 'drinks':
        return Icons.local_bar;
      default:
        return Icons.restaurant;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'pizza':
        return Colors.red;
      case 'pasta':
        return Colors.orange;
      case 'desserts':
        return Colors.pink;
      case 'drinks':
        return Colors.blue;
      default:
        return Colors.grey;
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

  void _addToCart() {
    final location = context.read<LocationNotifier>().selectedLocation;
    if (location == null) return;

    final cart = context.read<CartNotifier>();
    cart.add(CartItem(
      itemId: widget.item.id,
      name: widget.item.name,
      size: widget.item.sizes[_selected],
      price: widget.item.prices[_selected],
      locationId: location.id,
      quantity: _quantity,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.item.name} adăugat în coș!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final location = context.watch<LocationNotifier>().selectedLocation;
    final inventory = context.watch<InventoryNotifier>();
    final isAvailable = location != null && inventory.isAvailable(item.id, location.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: _getCategoryColor(item.category),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(item.category),
                  size: 80,
                  color: _getCategoryColor(item.category),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Item name and description
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tags
            if (item.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                children: item.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: Colors.grey[200],
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            
            if (isAvailable) ...[
              // Size selection
              Text(
                'Alege mărimea:',
                style: Theme.of(context).textTheme.titleMedium,
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
                    selectedColor: _getCategoryColor(item.category).withOpacity(0.3),
                  );
                }),
              ),
              
              const SizedBox(height: 24),
              
              // Quantity selection
              Text(
                'Cantitate:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
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
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: const Text(
                  'Acest produs nu este disponibil la locația selectată.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
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
              backgroundColor: _getCategoryColor(item.category),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _addToCart,
          ),
        ),
      ) : null,
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'pizza':
        return Icons.local_pizza;
      case 'pasta':
        return Icons.ramen_dining;
      case 'desserts':
        return Icons.cake;
      case 'drinks':
        return Icons.local_bar;
      default:
        return Icons.restaurant;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'pizza':
        return Colors.red;
      case 'pasta':
        return Colors.orange;
      case 'desserts':
        return Colors.pink;
      case 'drinks':
        return Colors.blue;
      default:
        return Colors.grey;
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
    final location = context.watch<LocationNotifier>().selectedLocation;

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
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Dismissible(
                  key: ValueKey('$index${item.itemId}${item.size}'),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => cart.removeAt(index),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.name} (${item.size})',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(item.price * item.quantity).toStringAsFixed(2)} Lei',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => cart.decrement(index),
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => cart.increment(index),
                              ),
                            ],
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
              'Checkout (${cart.total.toStringAsFixed(2)} Lei)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              final method = await showDialog<String>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Checkout'),
                  content: const Text('Cum doriți să plătiți?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, 'Cash'),
                      child: const Text('Cash'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, 'Card'),
                      child: const Text('Card'),
                    ),
                  ],
                ),
              );
              
              if (method != null && context.mounted) {
                // Submit order to Firebase
                try {
                  await FirebaseFirestore.instance.collection('orders').add({
                    'items': cart.items.map((item) => {
                      'itemId': item.itemId,
                      'name': item.name,
                      'size': item.size,
                      'price': item.price,
                      'quantity': item.quantity,
                    }).toList(),
                    'total': cart.total,
                    'paymentMethod': method,
                    'locationId': location?.id,
                    'userId': FirebaseAuth.instance.currentUser?.uid,
                    'status': 'pending',
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Comandă plasată! Plată cu $method.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    cart.clear();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Eroare la plasarea comenzii: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
// Account / Sign In / Sign Up
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
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'Autentificat ca',
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
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Istoric comenzi'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to order history
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Setări'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to settings
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Ieșire din cont'),
                onTap: _signOut,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '', _error = '';

  Future<void> _submit() async {
    setState(() => _error = '');
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Autentificare eșuată: $e');
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
                Text(_error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (v) => _email = v!.trim(),
                validator: (v) => (v?.contains('@') ?? false) ? null : 'Email invalid',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Parolă'),
                obscureText: true,
                onSaved: (v) => _password = v!.trim(),
                validator: (v) => (v != null && v.length >= 6) ? null : 'Minim 6 caractere',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Autentificare'),
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
  String _email = '', _password = '', _confirm = '', _error = '';

  Future<void> _submit() async {
    setState(() => _error = '');
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();
    if (_password != _confirm) {
      setState(() => _error = 'Parolele nu coincid');
      return;
    }
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Cont creat!')));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = 'Înregistrare eșuată: $e');
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
                Text(_error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (v) => _email = v!.trim(),
                validator: (v) => (v?.contains('@') ?? false) ? null : 'Email invalid',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Parolă'),
                obscureText: true,
                onSaved: (v) => _password = v!.trim(),
                validator: (v) => (v != null && v.length >= 6) ? null : 'Minim 6 caractere',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Confirmă parola'),
                obscureText: true,
                onSaved: (v) => _confirm = v!.trim(),
                validator: (v) => (v != null && v.length >= 6) ? null : 'Minim 6 caractere',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Înregistrare'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}