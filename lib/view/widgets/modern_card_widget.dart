import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';

class ModernCardWidget extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isGlassmorphic;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final bool showShadow;
  final double borderRadius;
  final Border? border;
  final bool animated;
  final Duration animationDuration;

  const ModernCardWidget({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
    this.isGlassmorphic = false,
    this.backgroundColor,
    this.gradientColors,
    this.showShadow = true,
    this.borderRadius = 20.0,
    this.border,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  State<ModernCardWidget> createState() => _ModernCardWidgetState();
}

class _ModernCardWidgetState extends State<ModernCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.animated && widget.onTap != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.animated && widget.onTap != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.animated && widget.onTap != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget card = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin ?? EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
        border: widget.border ??
            (widget.isGlassmorphic
                ? Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  )
                : null),
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : AppTheme.shadowColor.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.15)
                      : AppTheme.shadowColor.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
        child: widget.isGlassmorphic
            ? _buildGlassmorphicCard(isDarkMode)
            : _buildRegularCard(isDarkMode),
      ),
    );

    if (widget.onTap != null) {
      card = GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: card,
      );
    }

    if (widget.animated) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: card,
          );
        },
      );
    }

    return card;
  }

  Widget _buildGlassmorphicCard(bool isDarkMode) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.gradientColors ??
                (isDarkMode
                    ? [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ]
                    : [
                        Colors.white.withOpacity(0.8),
                        Colors.white.withOpacity(0.4),
                      ]),
          ),
        ),
        child: Padding(
          padding: widget.padding ?? EdgeInsets.all(16.w),
          child: widget.child,
        ),
      ),
    );
  }

  Widget _buildRegularCard(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            (isDarkMode ? AppTheme.surfaceColor : Theme.of(context).cardColor),
        gradient: widget.gradientColors != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.gradientColors!,
              )
            : null,
      ),
      child: Padding(
        padding: widget.padding ?? EdgeInsets.all(16.w),
        child: widget.child,
      ),
    );
  }
}

// Özel kart türleri için wrapper'lar
class ModernTaskCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isCompleted;
  final Color? accentColor;

  const ModernTaskCard({
    Key? key,
    required this.child,
    this.onTap,
    this.isCompleted = false,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ModernCardWidget(
      onTap: onTap,
      borderRadius: 16,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      border: Border.all(
        color: (accentColor ?? AppTheme.primaryColor).withOpacity(0.2),
        width: 1,
      ),
      gradientColors: isCompleted
          ? [
              AppTheme.successColor.withOpacity(0.1),
              AppTheme.successColor.withOpacity(0.05),
            ]
          : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: accentColor ?? AppTheme.primaryColor,
              width: 4.w,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

class ModernInfoCard extends StatelessWidget {
  final Widget child;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const ModernInfoCard({
    Key? key,
    required this.child,
    this.icon,
    this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernCardWidget(
      onTap: onTap,
      isGlassmorphic: true,
      borderRadius: 20,
      margin: EdgeInsets.all(16.w),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppTheme.primaryColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}

class ModernStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const ModernStatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernCardWidget(
      onTap: onTap,
      gradientColors: [
        color.withOpacity(0.1),
        color.withOpacity(0.05),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.sp,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurfaceColor,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.onSurfaceVariantColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
