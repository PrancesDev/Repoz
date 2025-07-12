import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// This is a separate admin app for restaurant staff
// You would create this as a separate Flutter project

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Italianu\' - Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  
  static final List<Widget> _pages = <Widget>[
    const OrdersPage(),
    const InventoryPage(),
    const AnalyticsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('La Italianu\' - Admin Panel'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Comenzi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Stoc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analize',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setări',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Orders Management Page
// ─────────────────────────────────────────────────────────────────────────────

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Eroare: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data?.docs ?? [];

        if (orders.isEmpty) {
          return const Center(
            child: Text('Nu există comenzi'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final data = order.data() as Map<String, dynamic>;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text('Comanda #${order.id.substring(0, 8)}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total: ${data['total']?.toStringAsFixed(2) ?? '0.00'} Lei'),
                    Text('Status: ${_getStatusText(data['status'] ?? 'pending')}'),
                    Text('Locația: ${data['locationId'] ?? 'N/A'}'),
                  ],
                ),
                trailing: _buildStatusChip(data['status'] ?? 'pending'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Produse comandate:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...((data['items'] as List?) ?? []).map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('${item['name']} (${item['size']})'),
                                ),
                                Text('${item['quantity']}x'),
                                Text('${(item['price'] * item['quantity']).toStringAsFixed(2)} Lei'),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => _updateOrderStatus(order.id, 'preparing'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                              child: const Text('În preparare'),
                            ),
                            ElevatedButton(
                              onPressed: () => _updateOrderStatus(order.id, 'ready'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('Gata'),
                            ),
                            ElevatedButton(
                              onPressed: () => _updateOrderStatus(order.id, 'delivered'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              child: const Text('Livrat'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'preparing':
        color = Colors.blue;
        break;
      case 'ready':
        color = Colors.green;
        break;
      case 'delivered':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        _getStatusText(status),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'În așteptare';
      case 'preparing':
        return 'În preparare';
      case 'ready':
        return 'Gata';
      case 'delivered':
        return 'Livrat';
      default:
        return 'Necunoscut';
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});
    } catch (e) {
      print('Error updating order status: $e');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inventory Management Page
// ─────────────────────────────────────────────────────────────────────────────

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});
  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String selectedLocation = 'centru';
  
  final Map<String, String> locationNames = {
    'centru': 'Centru',
    'manastur': 'Mănăștur',
    'floresti': 'Florești',
  };

  final List<Map<String, dynamic>> menuItems = [
    {'id': 'pepperoni', 'name': 'Pepperoni', 'category': 'Pizza'},
    {'id': 'margherita', 'name': 'Margherita', 'category': 'Pizza'},
    {'id': 'quattro_formaggi', 'name': 'Quattro Formaggi', 'category': 'Pizza'},
    {'id': 'carbonara', 'name': 'Spaghetti Carbonara', 'category': 'Paste'},
    {'id': 'bolognese', 'name': 'Tagliatelle Bolognese', 'category': 'Paste'},
    {'id': 'pesto', 'name': 'Penne Pesto', 'category': 'Paste'},
    {'id': 'tiramisu', 'name': 'Tiramisu', 'category': 'Deserturi'},
    {'id': 'panna_cotta', 'name': 'Panna Cotta', 'category': 'Deserturi'},
    {'id': 'coca_cola', 'name': 'Coca Cola', 'category': 'Băuturi'},
    {'id': 'wine_red', 'name': 'Vin Roșu Casa', 'category': 'Băuturi'},
  ];

  // Simulated inventory data - in real app this would be in Firebase
  Map<String, Map<String, bool>> inventory = {
    'centru': {
      'pepperoni': true,
      'margherita': true,
      'quattro_formaggi': false,
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
      'carbonara': false,
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
      'pesto': false,
      'tiramisu': false,
      'panna_cotta': true,
      'coca_cola': true,
      'wine_red': true,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            value: selectedLocation,
            decoration: const InputDecoration(
              labelText: 'Selectează locația',
              border: OutlineInputBorder(),
            ),
            items: locationNames.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedLocation = value);
              }
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final isAvailable = inventory[selectedLocation]?[item['id']] ?? false;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item['name']),
                  subtitle: Text(item['category']),
                  trailing: Switch(
                    value: isAvailable,
                    onChanged: (value) {
                      setState(() {
                        inventory[selectedLocation]![item['id']] = value;
                      });
                      // In real app, update Firebase here
                    },
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isAvailable ? Colors.green : Colors.red,
                    child: Icon(
                      isAvailable ? Icons.check : Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Analytics Page
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Comenzi astăzi',
                '23',
                Icons.receipt_long,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Vânzări astăzi',
                '1,247 Lei',
                Icons.attach_money,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Comenzi în așteptare',
                '5',
                Icons.pending,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Timp mediu preparare',
                '18 min',
                Icons.timer,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Produse populare astăzi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPopularItem('Pepperoni', '8 comenzi'),
                _buildPopularItem('Margherita', '6 comenzi'),
                _buildPopularItem('Carbonara', '5 comenzi'),
                _buildPopularItem('Quattro Formaggi', '4 comenzi'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Performanță locații',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLocationPerformance('Centru', '45%', '567 Lei'),
                _buildLocationPerformance('Mănăștur', '35%', '436 Lei'),
                _buildLocationPerformance('Florești', '20%', '244 Lei'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularItem(String name, String orders) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text(
            orders,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPerformance(String location, String percentage, String sales) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(location)),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: double.parse(percentage.replaceAll('%', '')) / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(percentage)),
          Expanded(child: Text(sales)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings Page
// ─────────────────────────────────────────────────────────────────────────────

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.restaurant),
                title: const Text('Gestionare meniu'),
                subtitle: const Text('Adaugă, editează sau șterge produse'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to menu management
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Gestionare locații'),
                subtitle: const Text('Configurează restaurantele'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to location management
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Gestionare personal'),
                subtitle: const Text('Adaugă sau elimină utilizatori admin'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to staff management
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notificări'),
                subtitle: const Text('Configurează alertele pentru comenzi noi'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // Toggle notifications
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Timp estimat preparare'),
                subtitle: const Text('Setează timpul mediu de preparare'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to time settings
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup date'),
                subtitle: const Text('Exportă datele restaurantului'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Backup data
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Ajutor și suport'),
                subtitle: const Text('Contactează echipa de suport'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to help
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}