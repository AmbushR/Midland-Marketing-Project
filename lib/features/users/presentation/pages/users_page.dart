import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midlandmarketing/core/di/injection.dart';
import 'package:midlandmarketing/core/theme/app_colors.dart';
import 'package:midlandmarketing/core/widgets/app_card.dart';
import 'package:midlandmarketing/core/widgets/empty_state.dart';
import 'package:midlandmarketing/core/widgets/error_view.dart';
import 'package:midlandmarketing/core/widgets/role_badge.dart';
import 'package:midlandmarketing/core/widgets/user_avatar.dart';
import 'package:midlandmarketing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:midlandmarketing/features/users/domain/entities/user.dart';
import 'package:midlandmarketing/features/users/presentation/bloc/users_bloc.dart';
import 'package:midlandmarketing/features/users/presentation/widgets/add_user_sheet.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UsersBloc>()..add(const UsersRequested()),
      child: const _UsersView(),
    );
  }
}

class _UsersView extends StatefulWidget {
  const _UsersView();

  @override
  State<_UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<_UsersView> {
  String _query = '';
  UserRole? _role;

  void _openAddUser(BuildContext context) {
    final actor = context.read<AuthBloc>().state.user;
    if (actor == null) return;

    final bloc = context.read<UsersBloc>()..add(const UserSaveReset());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: AddUserSheet(actor: actor),
      ),
    );
  }

  List<User> _filter(List<User> users) {
    final query = _query.trim().toLowerCase();
    return [
      for (final user in users)
        if ((_role == null || user.role == _role) &&
            (query.isEmpty ||
                user.name.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query)))
          user,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsersBloc, UsersState>(
      listenWhen: (previous, current) =>
          previous.saveStatus != UserSaveStatus.success &&
          current.saveStatus == UserSaveStatus.success,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(state.saveMessage ?? 'User added.')),
          );
        context.read<UsersBloc>().add(const UserSaveReset());
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Team members')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openAddUser(context),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text(
            'Add user',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: BlocBuilder<UsersBloc, UsersState>(
          builder: (context, state) {
            switch (state.status) {
              case UsersStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case UsersStatus.failure:
                return ErrorView(
                  message: state.errorMessage ?? 'Something went wrong.',
                  onRetry: () =>
                      context.read<UsersBloc>().add(const UsersRequested()),
                );
              case UsersStatus.loaded:
                return _buildLoaded(context, state.users);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, List<User> users) {
    final visible = _filter(users);
    int count(UserRole role) => users.where((u) => u.role == role).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search by name or email',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterPill(
                      label: 'All  ${users.length}',
                      selected: _role == null,
                      onTap: () => setState(() => _role = null),
                    ),
                    for (final role in UserRole.values) ...[
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: '${role.label}  ${count(role)}',
                        selected: _role == role,
                        onTap: () => setState(() => _role = role),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? const EmptyState(
                  icon: Icons.person_search_outlined,
                  message: 'No users match your search.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _UserTile(user: visible[index]),
                ),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? AppColors.primary : AppColors.ink,
      ),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          UserAvatar(name: user.name, role: user.role, size: 50),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                RoleBadge(role: user.role),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
