import 'package:flutter/material.dart';

import '../data/sample_camps.dart';
import '../data/sample_communities.dart';
import '../data/sample_other_users.dart';
import '../models/camp.dart';
import '../models/community.dart';
import '../models/followable_user.dart';
import '../theme/app_theme.dart';
import 'camp_details_screen.dart';
import 'camp_results_screen.dart';
import 'community_feed_screen.dart';
import 'other_user_profile_screen.dart';

enum _SearchFacet { all, camps, communities, people, locations, activities }

extension on _SearchFacet {
  String get label => switch (this) {
    _SearchFacet.all => 'All',
    _SearchFacet.camps => 'Camps',
    _SearchFacet.communities => 'Communities',
    _SearchFacet.people => 'People',
    _SearchFacet.locations => 'Locations',
    _SearchFacet.activities => 'Activities',
  };
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryController = TextEditingController();
  _SearchFacet _facet = _SearchFacet.all;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  String get _rawQuery => _queryController.text.trim();
  String get _query => _rawQuery.toLowerCase();

  List<Camp> get _matchingCamps => sampleCamps
      .where(
        (c) =>
            c.name.toLowerCase().contains(_query) ||
            c.location.toLowerCase().contains(_query),
      )
      .toList();

  List<Community> get _matchingCommunities => sampleCommunities
      .where(
        (c) =>
            c.name.toLowerCase().contains(_query) ||
            c.description.toLowerCase().contains(_query),
      )
      .toList();

  List<FollowableUser> get _matchingPeople => sampleOtherUsers
      .where(
        (u) =>
            u.profile.name.toLowerCase().contains(_query) ||
            u.profile.bio.toLowerCase().contains(_query),
      )
      .toList();

  List<String> get _matchingLocations =>
      {for (final c in sampleCamps) c.location}
          .where((l) => l.toLowerCase().contains(_query))
          .toList()
        ..sort();

  List<DiscoverCategory> get _matchingActivities => kDiscoverCategories
      .where((c) => c.label.toLowerCase().contains(_query))
      .toList();

  void _openCamp(Camp camp) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CampDetailsScreen(camp: camp)));
  }

  void _openCommunity(Community community) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityFeedScreen(community: community),
      ),
    );
  }

  void _openPerson(FollowableUser user) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OtherUserProfileScreen(user: user)),
    );
  }

  void _openLocation(String location) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CampResultsScreen(locationQuery: location),
      ),
    );
  }

  void _openActivity(DiscoverCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CampResultsScreen(category: category.label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    key: const Key('searchQueryField'),
                    controller: _queryController,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText:
                          'Search camps, communities, people, locations, activities',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _queryController.text.isEmpty
                          ? null
                          : IconButton(
                              key: const Key('searchClearButton'),
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setState(_queryController.clear),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final facet in _SearchFacet.values)
                          ChoiceChip(
                            key: Key('searchFacetChip_${facet.name}'),
                            label: Text(facet.label),
                            selected: _facet == facet,
                            onSelected: (_) => setState(() => _facet = facet),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: _buildResults(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    if (_query.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Search camps, communities, people, locations, and activities.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return switch (_facet) {
      _SearchFacet.all => _buildAllResults(context),
      _SearchFacet.camps => _buildList(
        items: _matchingCamps,
        emptyText: "No camps found for '$_rawQuery'.",
        rowBuilder: (camp) =>
            _SearchCampRow(camp: camp, onTap: () => _openCamp(camp)),
      ),
      _SearchFacet.communities => _buildList(
        items: _matchingCommunities,
        emptyText: "No communities found for '$_rawQuery'.",
        rowBuilder: (community) => _SearchCommunityRow(
          community: community,
          onTap: () => _openCommunity(community),
        ),
      ),
      _SearchFacet.people => _buildList(
        items: _matchingPeople,
        emptyText: "No people found for '$_rawQuery'.",
        rowBuilder: (user) =>
            _SearchPersonRow(user: user, onTap: () => _openPerson(user)),
      ),
      _SearchFacet.locations => _buildList(
        items: _matchingLocations,
        emptyText: "No locations found for '$_rawQuery'.",
        rowBuilder: (location) => ListTile(
          key: Key('searchLocationRow_$location'),
          leading: const Icon(Icons.place_outlined),
          title: Text(location),
          onTap: () => _openLocation(location),
        ),
      ),
      _SearchFacet.activities => _buildList(
        items: _matchingActivities,
        emptyText: "No activities found for '$_rawQuery'.",
        rowBuilder: (category) => ListTile(
          key: Key('searchActivityRow_${category.label}'),
          leading: Icon(category.icon),
          title: Text(category.label),
          onTap: () => _openActivity(category),
        ),
      ),
    };
  }

  Widget _buildList<T>({
    required List<T> items,
    required String emptyText,
    required Widget Function(T item) rowBuilder,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(emptyText, style: const TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: items.length,
      itemBuilder: (context, index) => rowBuilder(items[index]),
    );
  }

  Widget _buildAllResults(BuildContext context) {
    final sections = [
      ..._section(
        facet: _SearchFacet.camps,
        items: _matchingCamps,
        rowBuilder: (camp) =>
            _SearchCampRow(camp: camp, onTap: () => _openCamp(camp)),
      ),
      ..._section(
        facet: _SearchFacet.communities,
        items: _matchingCommunities,
        rowBuilder: (community) => _SearchCommunityRow(
          community: community,
          onTap: () => _openCommunity(community),
        ),
      ),
      ..._section(
        facet: _SearchFacet.people,
        items: _matchingPeople,
        rowBuilder: (user) =>
            _SearchPersonRow(user: user, onTap: () => _openPerson(user)),
      ),
      ..._section(
        facet: _SearchFacet.locations,
        items: _matchingLocations,
        rowBuilder: (location) => ListTile(
          key: Key('searchLocationRow_$location'),
          leading: const Icon(Icons.place_outlined),
          title: Text(location),
          onTap: () => _openLocation(location),
        ),
      ),
      ..._section(
        facet: _SearchFacet.activities,
        items: _matchingActivities,
        rowBuilder: (category) => ListTile(
          key: Key('searchActivityRow_${category.label}'),
          leading: Icon(category.icon),
          title: Text(category.label),
          onTap: () => _openActivity(category),
        ),
      ),
    ];

    if (sections.isEmpty) {
      return Center(
        child: Text(
          "No results for '$_rawQuery'.",
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView(padding: const EdgeInsets.all(16), children: sections);
  }

  List<Widget> _section<T>({
    required _SearchFacet facet,
    required List<T> items,
    required Widget Function(T item) rowBuilder,
  }) {
    if (items.isEmpty) return const [];
    const cap = 3;
    final visible = items.take(cap).toList();
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          '${facet.label} (${items.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      for (final item in visible) rowBuilder(item),
      if (items.length > cap)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            key: Key('searchSeeAll_${facet.name}'),
            onPressed: () => setState(() => _facet = facet),
            child: Text('See all in ${facet.label}'),
          ),
        ),
    ];
  }
}

class _SearchCampRow extends StatelessWidget {
  const _SearchCampRow({required this.camp, required this.onTap});

  final Camp camp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      key: Key('searchCampRow_${camp.id}'),
      leading: Icon(
        camp.primaryIcon,
        color: isDark ? AppColors.brandDark : AppColors.brand,
      ),
      title: Text(camp.name),
      subtitle: Text(camp.location),
      onTap: onTap,
    );
  }
}

class _SearchCommunityRow extends StatelessWidget {
  const _SearchCommunityRow({required this.community, required this.onTap});

  final Community community;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      key: Key('searchCommunityRow_${community.id}'),
      leading: Icon(
        community.icon,
        color: isDark ? AppColors.brandDark : AppColors.brand,
      ),
      title: Text(community.name),
      subtitle: Text('${community.memberCount} members'),
      onTap: onTap,
    );
  }
}

class _SearchPersonRow extends StatelessWidget {
  const _SearchPersonRow({required this.user, required this.onTap});

  final FollowableUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      key: Key('searchPersonRow_${user.profile.name}'),
      leading: CircleAvatar(
        backgroundColor: isDark
            ? AppColors.brandDark.withValues(alpha: 0.25)
            : AppColors.brand.withValues(alpha: 0.12),
        child: Text(
          user.profile.initials,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: isDark ? AppColors.brandDark : AppColors.brand,
          ),
        ),
      ),
      title: Text(user.profile.name),
      subtitle: Text(user.profile.bio, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}
