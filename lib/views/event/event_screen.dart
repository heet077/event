import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../auth/login_screen.dart';
import 'event_details_screen.dart';
import 'add_event_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../custom_widget/custom_searchbar.dart';

/// ----------------------
/// Riverpod Providers
/// ----------------------
final eventListProvider = StateNotifierProvider<EventListNotifier, List<Map<String, dynamic>>>(
      (ref) => EventListNotifier(),
);
final filteredEventNamesProvider = StateProvider<List<String>>((ref) => []);

class EventListNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  EventListNotifier() : super([]);
  void addEvent(Map<String, dynamic> event) => state = [...state, event];
  void clear() => state = [];
}

/// ----------------------
/// Event Screen
/// ----------------------
class EventScreen extends ConsumerStatefulWidget {
  final bool isAdmin;
  const EventScreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSearchBarVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initialize filtered events with all event names
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final allEvents = ref.read(eventListProvider).map((e) => e['name'] as String).toList();
      ref.read(filteredEventNamesProvider.notifier).state = allEvents;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && _isSearchBarVisible) {
      setState(() => _isSearchBarVisible = false);
    } else if (_scrollController.offset <= 50 && !_isSearchBarVisible) {
      setState(() => _isSearchBarVisible = true);
    }
  }

  void _filterEvents(String query) {
    final q = query.toLowerCase();
    final allEvents = ref.read(eventListProvider).map((e) => e['name'] as String).toList();
    ref.read(filteredEventNamesProvider.notifier).state = q.isEmpty
        ? List.from(allEvents)
        : allEvents.where((event) => event.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allEventsData = ref.watch(eventListProvider);
    final filteredEvents = ref.watch(filteredEventNamesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Events',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, Colors.white],
            stops: [0.0, 0.25],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isSearchBarVisible ? 96 : 0, // 56 height + 20 top + 20 bottom
                child: _isSearchBarVisible
                    ? Container(
                        margin: const EdgeInsets.all(20),
                        child: CustomSearchBar(
                          hintText: 'Search events...',
                          debounceMs: 250,
                          onQueryChanged: _filterEvents,
                          onSubmitted: _filterEvents,
                          padding: EdgeInsets.zero,
                          borderRadius: 20,
                          height: 56,
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.secondary.withOpacity(0.1),
                                    AppColors.secondary.withOpacity(0.05),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.search_off,
                                size: 60,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No events found',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try searching with different keywords',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          final eventName = filteredEvents[index];
                          final eventData = allEventsData.firstWhere(
                                (e) => e['name'] == eventName,
                            orElse: () => {},
                          );
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  AppColors.secondary.withOpacity(0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 25,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.grey.shade100,
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () {
                                  if (eventData.isNotEmpty) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => EventDetailsScreen(
                                          eventData: eventData,
                                          isAdmin: widget.isAdmin,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.primary,
                                              AppColors.primary.withOpacity(0.8),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(18),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withOpacity(0.3),
                                              blurRadius: 15,
                                              spreadRadius: 0,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.event,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              eventName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Tap to view details',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.primary.withOpacity(0.1),
                                              AppColors.primary.withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: AppColors.primary.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
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
      floatingActionButton: widget.isAdmin
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 0,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () async {
                  final newEvent = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddEventScreen()),
                  );
                  if (newEvent != null && newEvent is Map<String, dynamic>) {
                    ref.read(eventListProvider.notifier).addEvent(newEvent);
                    final allEvents =
                        ref.read(eventListProvider).map((e) => e['name'] as String).toList();
                    ref.read(filteredEventNamesProvider.notifier).state = allEvents;
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                label: const Text(
                  'Add Event',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            )
          : null,
    );
  }
}
