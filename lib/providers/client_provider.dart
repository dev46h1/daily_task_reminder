import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/client.dart';
import '../services/database_service.dart';

class ClientProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  List<Client> _clients = [];
  List<Client> _filteredClients = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Client> get clients => _filteredClients;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadClients() async {
    _isLoading = true;
    notifyListeners();

    try {
      _clients = await _db.getAllClients();
      _filteredClients = _clients;
    } catch (e) {
      debugPrint('Error loading clients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Client?> getClient(String id) async {
    try {
      return await _db.getClient(id);
    } catch (e) {
      debugPrint('Error getting client: $e');
      return null;
    }
  }

  Future<bool> addClient({
    required String name,
    required String phoneNumber,
    String? secondaryPhone,
    String? address,
    String? email,
    String? notes,
  }) async {
    try {
      // Check for duplicate phone number
      final existing = _clients.where((c) => c.phoneNumber == phoneNumber).toList();
      if (existing.isNotEmpty) {
        return false; // Duplicate found
      }

      final now = DateTime.now();
      final client = Client(
        id: 'CLI-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        phoneNumber: phoneNumber,
        secondaryPhone: secondaryPhone,
        address: address,
        email: email,
        notes: notes,
        registrationDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await _db.createClient(client);
      await loadClients();
      return true;
    } catch (e) {
      debugPrint('Error adding client: $e');
      return false;
    }
  }

  Future<bool> updateClient(Client client) async {
    try {
      final updatedClient = client.copyWith(updatedAt: DateTime.now());
      await _db.updateClient(updatedClient);
      await loadClients();
      return true;
    } catch (e) {
      debugPrint('Error updating client: $e');
      return false;
    }
  }

  Future<bool> deleteClient(String id) async {
    try {
      await _db.deleteClient(id);
      await loadClients();
      return true;
    } catch (e) {
      debugPrint('Error deleting client: $e');
      return false;
    }
  }

  void searchClients(String query) {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _filteredClients = _clients;
    } else {
      _filteredClients = _clients.where((client) {
        return client.name.toLowerCase().contains(query.toLowerCase()) ||
               client.phoneNumber.contains(query);
      }).toList();
    }
    
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredClients = _clients;
    notifyListeners();
  }
}
