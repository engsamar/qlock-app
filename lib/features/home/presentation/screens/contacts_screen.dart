import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:q_lock/core/constants/app_colors.dart';
import 'package:q_lock/core/constants/app_strings.dart';
import 'package:q_lock/core/di.dart';
import 'package:q_lock/core/widgets/gradient_background.dart';
import 'package:q_lock/features/home/presentation/logic/contacts/contacts_cubit.dart';
import 'package:q_lock/features/home/presentation/logic/contacts/contacts_state.dart';

import '../../../../core/routes/app_routes.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ContactsCubit>()..loadContacts(),
      child: const _ContactsScreenContent(),
    );
  }
}

class _ContactsScreenContent extends StatelessWidget {
  const _ContactsScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.contacts.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ContactsCubit>().loadContacts(),
            tooltip: AppStrings.refreshContacts.tr(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: BlocConsumer<ContactsCubit, ContactsState>(
            listenWhen:
                (previous, current) =>
                    previous.conversationStatus != current.conversationStatus,
            listener: (context, state) {
              if (state.conversationStatus == ConversationStatus.success) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.chat,
                  arguments: state.chat,
                );
              } else if (state.conversationStatus ==
                  ConversationStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.conversationErrorMessage ??
                          AppStrings.conversationFailed.tr(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state.contactsStatus == ContactsStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.contactsStatus == ContactsStatus.permissionDenied) {
                return Center(
                  child: Text(
                    AppStrings.permissionDenied.tr(),
                    style: TextStyle(color: AppColors.white, fontSize: 18.sp),
                  ),
                );
              }

              if (state.contactsStatus == ContactsStatus.failure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.errorLoadingContacts.tr(),
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18.sp,
                        ),
                      ),
                      if (state.contactsErrorMessage != null)
                        Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Text(
                            state.contactsErrorMessage!,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      TextButton(
                        onPressed:
                            () => context.read<ContactsCubit>().loadContacts(),
                        child: Text(AppStrings.refreshContacts.tr()),
                      ),
                    ],
                  ),
                );
              }

              if (state.contactsStatus == ContactsStatus.success) {
                final contacts = state.contacts;

                if (contacts.isEmpty) {
                  return Center(
                    child: Text(
                      AppStrings.noContactsWithNumbers.tr(),
                      style: TextStyle(color: AppColors.white, fontSize: 18.sp),
                    ),
                  );
                }

                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh:
                          () => context.read<ContactsCubit>().loadContacts(),
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.r),
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final contactWithPhone = contacts[index];
                          final contact = contactWithPhone.contact;
                          final phone = contactWithPhone.phone;

                          return Card(
                            margin: EdgeInsets.only(bottom: 8.h),
                            color: AppColors.lightGrey.withOpacity(0.1),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                backgroundImage:
                                    contact.photo != null
                                        ? MemoryImage(contact.photo!)
                                        : null,
                                child:
                                    contact.photo == null
                                        ? Text(
                                          contact.displayName[0].toUpperCase(),
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 18.sp,
                                          ),
                                        )
                                        : null,
                              ),
                              title: Text(
                                contact.displayName,
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  if (contact.phones.length > 1)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                        vertical: 2.h,
                                      ),
                                      margin: EdgeInsets.only(right: 4.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
                                      child: Text(
                                        phone.label.name,
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: AppColors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      phone.number,
                                      style: TextStyle(
                                        color: AppColors.black.withOpacity(0.7),
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                context.read<ContactsCubit>().startConversation(
                                  phone.normalizedNumber,
                                  contact.displayName,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    if (state.conversationStatus == ConversationStatus.loading)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              SizedBox(height: 16.h),
                              Text(
                                AppStrings.startingConversation.tr(),
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
