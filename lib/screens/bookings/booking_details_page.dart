import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';
import '../../models/booking/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../services/chat_api_service.dart';
import '../../providers/user_search_provider.dart';
import '../chat/chat_detail_page.dart';
import 'completed_booking_details_page.dart';

class BookingDetailsPage extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailsPage({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  BookingProvider? _bookingProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store provider reference when dependencies are available
    _bookingProvider = Provider.of<BookingProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    // Clear booking details when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _bookingProvider != null) {
        _bookingProvider!.clearBookingDetails();
      }
    });
  }

  @override
  void dispose() {
    // Clear booking details when page is disposed
    // Use stored reference instead of accessing context
    if (_bookingProvider != null) {
      _bookingProvider!.clearBookingDetails();
    }
    super.dispose();
  }

  Future<void> _handleStartBooking() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final updatedBooking = await bookingProvider.updateBookingStatus(
      bookingId: widget.booking.bookingId,
      status: 'in_progress',
    );

    if (updatedBooking != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking started successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      // Refresh bookings list
      await bookingProvider.refreshBookings();
      // Pop back to bookings list
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage ?? 'Failed to start booking'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleCompleteBooking() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    
    // Convert extra charges to API format
    List<Map<String, dynamic>>? chargesList;
    if (bookingProvider.extraCharges.isNotEmpty) {
      chargesList = bookingProvider.extraCharges.map((charge) => {
        'label': charge.name,
        'amount': charge.price,
      }).toList();
    }

    final updatedBooking = await bookingProvider.updateBookingStatus(
      bookingId: widget.booking.bookingId,
      status: 'completed',
    );

    if (updatedBooking != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking completed successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      // Navigate to completed booking page with service notes and extra charges
      final serviceNotes = bookingProvider.serviceNotes.isNotEmpty 
          ? List<String>.from(bookingProvider.serviceNotes) 
          : null;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CompletedBookingDetailsPage(
            booking: updatedBooking,
            serviceNotes: serviceNotes,
            extraCharges: chargesList,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage ?? 'Failed to complete booking'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Main Content
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.screenPaddingHorizontal,
                        vertical: AppDimensions.screenPaddingVertical,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppDimensions.verticalSpaceS),
                          
                          // Back Button and Title Row
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary,
                                  size: AppDimensions.iconM,
                                ),
                                onPressed: () => Navigator.pop(context),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                              SizedBox(width: AppDimensions.paddingM),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'New Job Requests',
                                    style: AppTextStyles.appBarTitle.copyWith(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.onBackground,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: AppDimensions.iconM + AppDimensions.paddingM),
                            ],
                          ),
                          
                          SizedBox(height: AppDimensions.verticalSpaceL),
                
                  // Customer Info Card
                  _buildCustomerInfoCard(),
                  
                  SizedBox(height: AppDimensions.verticalSpaceM),
                  
                  // Service Details Card
                  _buildServiceDetailsCard(),
                  
                  SizedBox(height: AppDimensions.verticalSpaceM),
                  
                  // Pricing & Payments Card
                  _buildPricingCard(),
                  
                  // Service Notes and Extra Charges containers (only for in_progress status)
                  if (widget.booking.status.toLowerCase() == 'in_progress') ...[
                    SizedBox(height: AppDimensions.verticalSpaceM),
                    _buildServiceNotesContainer(),
                    SizedBox(height: AppDimensions.verticalSpaceM),
                    _buildExtraChargesContainer(),
                  ],
                  
                  SizedBox(height: AppDimensions.verticalSpaceXL),
                          // Show button based on status
                          if (widget.booking.status.toLowerCase() == 'confirmed')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                ),
                                onPressed: bookingProvider.isUpdatingStatus ? null : _handleStartBooking,
                                child: Text('Start Booking', style: AppTextStyles.buttonLarge),
                              ),
                            )
                          else if (widget.booking.status.toLowerCase() == 'in_progress')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                ),
                                onPressed: bookingProvider.isUpdatingStatus ? null : _handleCompleteBooking,
                                child: Text('Complete Booking', style: AppTextStyles.buttonLarge),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Loader Overlay
            if (bookingProvider.isUpdatingStatus)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      strokeWidth: 2,
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

  Widget _buildCustomerInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: AppDimensions.shadowBlurRadius,
            offset: Offset(0, AppDimensions.shadowOffset),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Info',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceM),
          // Customer Info Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 28.r,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                backgroundImage: widget.booking.customerProfilePicture != null
                    ? NetworkImage(widget.booking.customerProfilePicture!)
                    : null,
                child: widget.booking.customerProfilePicture == null
                    ? Icon(
                        Icons.person,
                        size: AppDimensions.iconL,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              SizedBox(width: AppDimensions.paddingM),
              // Customer Name and Location - Expanded to take remaining space
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.booking.customerName,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: AppDimensions.verticalSpaceXS),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: AppDimensions.iconS,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: AppDimensions.paddingXS),
                        Expanded(
                          child: Text(
                            widget.booking.location,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Distance, View on Map, and Contact Buttons in one row
          Padding(
            padding: EdgeInsets.only(top: AppDimensions.verticalSpaceS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Distance and View on Map on the left
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.booking.distance != null)
                      Text(
                        widget.booking.distance!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    SizedBox(height: 4.h),
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to map view
                      },
                      child: Text(
                        'View on Map',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                // Contact Buttons on the right
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildContactButton(
                      icon: Icons.message,
                      onTap: () => _sendMessage(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Theme.of(context).colorScheme.primary,
          size: AppDimensions.iconM,
        ),
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: AppDimensions.shadowBlurRadius,
            offset: Offset(0, AppDimensions.shadowOffset),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Details',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          // Service Type
          Text(
            widget.booking.serviceName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          // Appointment Time
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: AppDimensions.iconS,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: AppDimensions.paddingS),
              Text(
                '${widget.booking.date} at ${widget.booking.time}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          // Estimated Duration
          if (widget.booking.estimatedDuration != null) ...[
            Text(
              'Estimated Duration: ${widget.booking.estimatedDuration}',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppDimensions.verticalSpaceS),
          ],
          // Service Notes
          Text(
            'Service Notes',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.outline,
              )
            ),
            child: Text(
              widget.booking.serviceNotes ?? 'No notes provided',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: AppDimensions.shadowBlurRadius,
            offset: Offset(0, AppDimensions.shadowOffset),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing & Payments',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          // Offered Rate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Offered Rate:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700

                    ),
                  ),
                  SizedBox(height: AppDimensions.verticalSpaceXS),
                  Text(
                    'Incl. visit charges',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                '\$${widget.booking.price.toStringAsFixed(0)}',
                style: AppTextStyles.priceText.copyWith(
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.verticalSpaceM),
          // Additional Charges
          Text(
            'Additional charges: additional charges can be added after job completion.',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }



  Future<void> _sendMessage() async {
    if (widget.booking.customerId == null || widget.booking.customerId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer information not available'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );

      // Create chat room with customer using UserSearchProvider
      final searchProvider = Provider.of<UserSearchProvider>(context, listen: false);
      final chatRoom = await searchProvider.createChatRoomWithUser(widget.booking.customerId!);

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (chatRoom != null && mounted) {
        // Navigate to chat detail page with room ID
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              roomId: chatRoom.id,
              contactName: widget.booking.customerName,
              contactProfileImageUrl: widget.booking.customerProfilePicture,
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(searchProvider.createRoomError ?? 'Failed to open chat. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening chat: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _addServiceNote() {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController noteController = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
          ),
          title: Text(
            'Add Service Note',
            style: AppTextStyles.titleLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: TextField(
            controller: noteController,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Enter service note',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (noteController.text.trim().isNotEmpty) {
                  bookingProvider.addServiceNote(noteController.text.trim());
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Add',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addExtraCharge() async {
    if (!mounted) return;
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _AddExtraChargeDialog(
        onAdd: (name, price) {
          bookingProvider.addExtraCharge(ExtraCharge(name: name, price: price));
        },
      ),
    );
  }

  Widget _buildServiceNotesContainer() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: AppDimensions.shadowBlurRadius,
            offset: Offset(0, AppDimensions.shadowOffset),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Add details and Add button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add details section
                    Text(
                      'Add details',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: AppDimensions.verticalSpaceM),
                    Text(
                      'Service Notes',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              // Add button at top right
              GestureDetector(
                onTap: _addServiceNote,
                child: Container(
                  width: 35.w,
                  height: 35.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    shape: BoxShape.rectangle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: AppDimensions.iconM,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.verticalSpaceS),
          // Service Notes Tags
          Wrap(
            spacing: AppDimensions.paddingS,
            runSpacing: AppDimensions.paddingS,
            children: [
              ...bookingProvider.serviceNotes.map((note) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: AppDimensions.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    child: Text(
                      note,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildExtraChargesContainer() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: AppDimensions.shadowBlurRadius,
            offset: Offset(0, AppDimensions.shadowOffset),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Extra Charges and Add button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Extra Charges',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              // Add button at top right
              GestureDetector(
                onTap: _addExtraCharge,
                child: Container(
                  width: 35.w,
                  height: 35.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    shape: BoxShape.rectangle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: AppDimensions.iconM,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.verticalSpaceM),
          // Extra Charges List
          if (bookingProvider.extraCharges.isEmpty)
            Text(
              'No extra charges added',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...bookingProvider.extraCharges.map((charge) => Padding(
                  padding: EdgeInsets.only(
                    bottom: AppDimensions.verticalSpaceS,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          charge.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        '\$${charge.price.toStringAsFixed(0)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
      },
    );
  }
}

class _AddExtraChargeDialog extends StatefulWidget {
  final Function(String name, double price) onAdd;

  const _AddExtraChargeDialog({required this.onAdd});

  @override
  State<_AddExtraChargeDialog> createState() => _AddExtraChargeDialogState();
}

class _AddExtraChargeDialogState extends State<_AddExtraChargeDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();
    
    setState(() {
      _errorMessage = null;
    });
    
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a charge name';
      });
      return;
    }
    
    if (priceText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a price';
      });
      return;
    }
    
    final price = double.tryParse(priceText);
    if (price == null || price < 0) {
      setState(() {
        _errorMessage = 'Please enter a valid price';
      });
      return;
    }
    
    widget.onAdd(name, price);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
      ),
      title: Text(
        'Add Extra Charge',
        style: AppTextStyles.titleLarge.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'e.g., Extra Pipe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                ),
              ),
              autofocus: true,
            ),
            SizedBox(height: AppDimensions.verticalSpaceM),
            TextField(
              controller: _priceController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'e.g., 200',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                ),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: AppDimensions.verticalSpaceS),
              Text(
                _errorMessage!,
                style: AppTextStyles.inputError,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTextStyles.buttonMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: _handleAdd,
          child: Text(
            'Add',
            style: AppTextStyles.buttonMedium.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

