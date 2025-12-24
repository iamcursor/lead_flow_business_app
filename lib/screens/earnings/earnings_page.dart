import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/earnings/earnings_model.dart';
import '../../providers/earnings_provider.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_dimensions.dart';
import '../../styles/app_text_styles.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  String _selectedRange = 'This Month';

  @override
  void initState() {
    super.initState();
    // Fetch earnings when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EarningsProvider>(context, listen: false);
      provider.fetchEarnings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<EarningsProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Main Content
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: () => provider.refreshEarnings(),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.screenPaddingHorizontal,
                              vertical: AppDimensions.screenPaddingVertical,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: AppDimensions.verticalSpaceS),
                                
                                // Title
                                Center(
                                  child: Text(
                                    'Earnings',
                                    style: AppTextStyles.appBarTitle.copyWith(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: AppDimensions.verticalSpaceL),
                                
                                // Date/Range Selection Tabs
                                _buildRangeTabs(),
                                
                                SizedBox(height: AppDimensions.verticalSpaceL),
                                
                                // Error State
                                if (provider.errorMessage != null && provider.earningsSummary == null)
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: AppDimensions.verticalSpaceXL,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            provider.errorMessage!,
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: AppColors.error,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: AppDimensions.verticalSpaceM),
                                          ElevatedButton(
                                            onPressed: () => provider.fetchEarnings(),
                                            child: Text('Retry'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                // Content
                                else if (provider.earningsSummary != null)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Earnings Summary Section
                                      _buildEarningsSummary(provider),
                                      
                                      SizedBox(height: AppDimensions.verticalSpaceXL),
                                      
                                      // Daily Earnings Section
                                      _buildDailyEarnings(provider),
                                      
                                      SizedBox(height: AppDimensions.verticalSpaceXL),
                                      
                                      // Job Wise Earnings Section
                                      _buildJobWiseEarnings(provider),
                                      
                                      SizedBox(height: AppDimensions.verticalSpaceXL),
                                      
                                      // Payout & Wallet Section
                                      _buildPayoutWallet(provider),
                                      
                                      // Bottom padding for scroll
                                      SizedBox(height: AppDimensions.verticalSpaceXL),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Loader Overlay
                        if (provider.isLoading)
                          Container(
                            color: Colors.transparent,
                            child: Center(
                              child: SizedBox(
                                width: 24.w,
                                height: 24.w,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryLight,
                                  ),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRangeTabs() {
    final ranges = ['This Month', 'Last Month', 'Customer Range'];
    
    return Row(
      children: ranges.map((range) {
        final isSelected = _selectedRange == range;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: range != ranges.last ? AppDimensions.paddingS : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRange = range;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    range,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEarningsSummary(EarningsProvider provider) {
    final summary = provider.earningsSummary!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earnings Summary',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppDimensions.verticalSpaceM),
        Row(
          children: [
            Expanded(
              child: _EarningsCard(
                icon: Icons.business,
                iconColor: AppColors.primaryLight,
                iconBackground: AppColors.backgroundSecondary,
                amount: '\$${summary.totalEarnings.toStringAsFixed(0)}',
                label: 'Total Earnings',
              ),
            ),
            SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: _EarningsCard(
                icon: Icons.check_circle,
                iconColor: AppColors.primaryLight,
                iconBackground: AppColors.backgroundSecondary,
                amount: summary.averagePerJob.toStringAsFixed(0),
                label: 'Average per Job',
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.verticalSpaceM),
        Row(
          children: [
            Expanded(
              child: _EarningsCard(
                icon: Icons.access_time,
                iconColor: AppColors.warning,
                iconBackground: AppColors.warningLight,
                amount: '\$${summary.pendingPayouts.toStringAsFixed(0)}',
                label: 'Pending Payouts',
              ),
            ),
            SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: _EarningsCard(
                icon: Icons.check_circle,
                iconColor: AppColors.success,
                iconBackground: AppColors.successLight,
                amount: summary.jobsCompleted.toString(),
                label: 'Jobs Completed',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyEarnings(EarningsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: AppDimensions.shadowBlurRadius,
            offset: Offset(0, AppDimensions.shadowOffset),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title inside container
          Padding(
            padding: EdgeInsets.all(AppDimensions.cardPadding),
            child: Text(
              'Daily Earnings',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            height: 170.h,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            child: _DailyEarningsChart(
              dailyEarnings: provider.dailyEarnings,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobWiseEarnings(EarningsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: AppDimensions.shadowBlurRadius,
            offset: Offset(0, AppDimensions.shadowOffset),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title inside container
          Padding(
            padding: EdgeInsets.all(AppDimensions.cardPadding),
            child: Text(
              'Job Wise Earnings',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...provider.jobEarnings.take(3).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final job = entry.value;
            final jobList = provider.jobEarnings.take(3).toList();
            final isLast = index == jobList.length - 1;
            
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(AppDimensions.cardPadding),
                  child: _JobEarningsEntry(
                    job: job,
                    onViewDetails: () {
                      // TODO: Navigate to job details
                    },
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderLight,
                  ),
              ],
            );
          }),
          // View All Button inside container
          Padding(
            padding: EdgeInsets.all(AppDimensions.cardPadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to all jobs
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                  ),
                ),
                child: Text(
                  'View All',
                  style: AppTextStyles.buttonMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutWallet(EarningsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: AppDimensions.shadowBlurRadius,
            offset: Offset(0, AppDimensions.shadowOffset),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title inside container
          Padding(
            padding: EdgeInsets.all(AppDimensions.cardPadding),
            child: Text(
              'Payout & Wallet',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppDimensions.cardPadding),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                  size: AppDimensions.iconL,
                ),
                SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wallet Balance',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppDimensions.verticalSpaceXS),
                      Text(
                        '\$${provider.walletBalance.toStringAsFixed(0)}',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 24.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // View All Button inside container
          Padding(
            padding: EdgeInsets.all(AppDimensions.cardPadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to payout details
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                  ),
                ),
                child: Text(
                  'View All',
                  style: AppTextStyles.buttonMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String amount;
  final String label;

  const _EarningsCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.amount,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: AppDimensions.shadowBlurRadius,
            offset: Offset(0, AppDimensions.shadowOffset),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: AppDimensions.iconM,
              ),
            ),
          ),
          SizedBox(height: AppDimensions.verticalSpaceM),
          Text(
            amount,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.verticalSpaceXS),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DailyEarningsChart extends StatelessWidget {
  final List<DailyEarning> dailyEarnings;

  const _DailyEarningsChart({
    required this.dailyEarnings,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyEarnings.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final maxEarning = 1200.0; // Fixed max value for consistent scaling
    final days = ['Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue'];
    final yAxisValues = [0, 300, 600, 900, 1200];
    final chartHeight = 128.h; // Reduced height for better alignment

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Y-axis labels
        SizedBox(
          width: 40.w,
          child: Stack(
            children: yAxisValues.reversed.map((value) {
              final position = (value / maxEarning) * chartHeight;
              return Positioned(
                top: chartHeight - position - 5.h, // Align text with grid line
                right: 8.w,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 2.h), // Fine-tune to align with grid line
                    child: Text(
                      '\$$value',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(width: 8.w),
        // Chart bars
        Expanded(
          child: Column(
            children: [
              // Chart area with grid lines
              SizedBox(
                height: chartHeight,
                child: Stack(
                  children: [
                    // Grid lines (dashed effect)
                    ...yAxisValues.map((value) {
                      final position = (value / maxEarning) * chartHeight;
                      return Positioned(
                        top: chartHeight - position,
                        left: 0,
                        right: 0,
                        child: CustomPaint(
                          painter: DashedLinePainter(color: AppColors.borderLight),
                          child: Container(
                            height: 1,
                          ),
                        ),
                      );
                    }),
                    // Bars
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        dailyEarnings.length > 9 ? 9 : dailyEarnings.length,
                        (index) {
                          final earning = dailyEarnings[index];
                          final height = (earning.amount / maxEarning) * chartHeight;
                          
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: height,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4.r),
                                        topRight: Radius.circular(4.r),
                                      ),
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
                ),
              ),
              SizedBox(height: 8.h),
              // X-axis labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  dailyEarnings.length > 9 ? 9 : dailyEarnings.length,
                  (index) {
                    return Expanded(
                      child: Text(
                        days[index % days.length],
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom painter for dashed grid lines
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _JobEarningsEntry extends StatelessWidget {
  final JobEarning job;
  final VoidCallback onViewDetails;

  const _JobEarningsEntry({
    required this.job,
    required this.onViewDetails,
  });

  Color _getStatusColor() {
    switch (job.status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (job.status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Job Title, Date/Time, Button
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title
              Text(
                job.jobTitle,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppDimensions.verticalSpaceS),
              // Date and Time Row
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: AppDimensions.iconS,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: AppDimensions.paddingS),
                  Text(
                    '${job.date} - ${job.time}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.verticalSpaceS),
              // View Details Button
              SizedBox(
                width: 170,
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 1),
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingS,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                    ),
                  ),
                  child: Text(
                    'View Details',
                    style: AppTextStyles.buttonSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppDimensions.paddingM),
        // Right side: Amount and Status
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Amount
            Text(
              '\$${job.amount.toStringAsFixed(0)}',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppDimensions.verticalSpaceS),
            // Status Row
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(),
                  size: AppDimensions.iconS,
                  color: _getStatusColor(),
                ),
                SizedBox(width: AppDimensions.paddingS),
                Text(
                  job.status,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

