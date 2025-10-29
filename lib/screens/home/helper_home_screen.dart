import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/help_request_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class HelperHomeScreen extends StatefulWidget {
  const HelperHomeScreen({super.key});

  @override
  State<HelperHomeScreen> createState() => _HelperHomeScreenState();
}

class _HelperHomeScreenState extends State<HelperHomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final userProvider = context.read<UserProvider>();
    setState(() {
      _isAvailable = userProvider.currentUser?.isAvailable ?? false;
    });
  }

  Future<void> _toggleAvailability() async {
    final userProvider = context.read<UserProvider>();
    final success = await userProvider.updateAvailability(!_isAvailable);
    
    if (success) {
      setState(() {
        _isAvailable = !_isAvailable;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isAvailable
                  ? 'You are now available for help requests'
                  : 'You are now unavailable',
            ),
            backgroundColor: _isAvailable ? Colors.green : Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Requests'),
        actions: [
          // Availability Toggle
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Text(
                  _isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    color: _isAvailable ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Switch(
                  value: _isAvailable,
                  onChanged: (value) => _toggleAvailability(),
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.currentUser;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<HelpRequestModel>>(
            stream: _firestoreService.getAvailableHelpRequests(
              categories: user.categories,
              maxDistance: user.serviceRadius,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final requests = snapshot.data ?? [];

              if (requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No help requests available',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for new opportunities',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _HelpRequestCard(request: request);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _HelpRequestCard extends StatelessWidget {
  final HelpRequestModel request;

  const _HelpRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to request details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: request.seekerPhotoUrl != null
                        ? NetworkImage(request.seekerPhotoUrl!)
                        : null,
                    child: request.seekerPhotoUrl == null
                        ? Text(request.seekerName[0].toUpperCase())
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.seekerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          timeago.format(request.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (request.urgency == UrgencyLevel.urgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (request.urgency == UrgencyLevel.emergency)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'EMERGENCY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                request.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                request.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),

              // Details
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _DetailChip(
                    icon: Icons.category_outlined,
                    label: request.getCategoryDisplayName(),
                  ),
                  _DetailChip(
                    icon: Icons.location_on_outlined,
                    label: request.location,
                  ),
                  _DetailChip(
                    icon: Icons.access_time,
                    label: '${request.estimatedDuration} min',
                  ),
                  if (request.suggestedTip != null)
                    _DetailChip(
                      icon: Icons.currency_rupee,
                      label: '₹${request.suggestedTip!.toStringAsFixed(0)}',
                      color: Colors.green,
                    ),
                  if (request.isIOYRequest)
                    _DetailChip(
                      icon: Icons.volunteer_activism,
                      label: 'I Owe You One',
                      color: Colors.purple,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Express interest
                  },
                  icon: const Icon(Icons.thumb_up_outlined),
                  label: const Text('I Can Help'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _DetailChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color ?? Colors.grey[700],
            fontWeight: color != null ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
}
