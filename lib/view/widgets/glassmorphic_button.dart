import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';

enum ButtonStyle {
  filled,
  outlined,
  text,
  glassmorphic,
  gradient,
  neumorphic,
}

class GlassmorphicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final ButtonStyle style;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final List<Color>? gradientColors;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool hapticFeedback;
  final Duration animationDuration;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Border? border;
  final double elevation;
  final bool fullWidth;

  const GlassmorphicButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.style = ButtonStyle.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.gradientColors,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 16.0,
    this.hapticFeedback = true,
    this.animationDuration = const Duration(milliseconds: 150),
    this.fontSize,
    this.fontWeight,
    this.border,
    this.elevation = 4.0,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  State<GlassmorphicButton> createState() => _GlassmorphicButtonState();
}

class _GlassmorphicButtonState extends State<GlassmorphicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
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
      end: 0.96,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation * 0.5,
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
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();

      if (widget.hapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: _handleTap,
            child: AnimatedOpacity(
              opacity: isEnabled ? 1.0 : 0.6,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: widget.fullWidth ? double.infinity : widget.width,
                height: widget.height ?? 50.h,
                padding: widget.padding ??
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: _buildDecoration(isDarkMode),
                child: _buildContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildDecoration(bool isDarkMode) {
    switch (widget.style) {
      case ButtonStyle.glassmorphic:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : AppTheme.shadowColor.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: _elevationAnimation.value * 2,
              offset: Offset(0, _elevationAnimation.value),
            ),
          ],
        );

      case ButtonStyle.gradient:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.gradientColors ??
                (isDarkMode
                    ? Constants.darkPrimaryGradient
                    : Constants.primaryGradient),
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.gradientColors?.first ?? AppTheme.primaryColor)
                  .withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: _elevationAnimation.value * 2,
              offset: Offset(0, _elevationAnimation.value),
            ),
          ],
          border: widget.border,
        );

      case ButtonStyle.neumorphic:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          color: widget.backgroundColor ??
              (isDarkMode ? AppTheme.surfaceColor : Colors.grey.shade200),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: isDarkMode ? Colors.black26 : Colors.grey.shade300,
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDarkMode ? Colors.black54 : Colors.grey.shade400,
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                    offset: const Offset(-4, -4),
                    blurRadius: 8,
                  ),
                ],
          border: widget.border,
        );

      case ButtonStyle.outlined:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          border: widget.border ??
              Border.all(
                color: widget.backgroundColor ?? AppTheme.primaryColor,
                width: 2,
              ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : AppTheme.shadowColor.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: _elevationAnimation.value,
              offset: Offset(0, _elevationAnimation.value * 0.5),
            ),
          ],
        );

      case ButtonStyle.text:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
        );

      case ButtonStyle.filled:
      default:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          color: widget.backgroundColor ?? AppTheme.primaryColor,
          boxShadow: [
            BoxShadow(
              color: (widget.backgroundColor ?? AppTheme.primaryColor)
                  .withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: _elevationAnimation.value * 2,
              offset: Offset(0, _elevationAnimation.value),
            ),
          ],
          border: widget.border,
        );
    }
  }

  Widget _buildContent() {
    Widget content;

    if (widget.isLoading) {
      content = SizedBox(
        width: 20.w,
        height: 20.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getTextColor(),
          ),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            widget.icon!,
            SizedBox(width: 8.w),
          ],
          Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize ?? 16.sp,
              fontWeight: widget.fontWeight ?? FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
        ],
      );
    }

    if (widget.style == ButtonStyle.glassmorphic) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
            child: Center(child: content),
          ),
        ),
      );
    }

    return Center(child: content);
  }

  Color _getTextColor() {
    if (widget.foregroundColor != null) {
      return widget.foregroundColor!;
    }

    switch (widget.style) {
      case ButtonStyle.outlined:
      case ButtonStyle.text:
        return widget.backgroundColor ?? AppTheme.primaryColor;
      case ButtonStyle.glassmorphic:
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87;
      case ButtonStyle.neumorphic:
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : Colors.black87;
      case ButtonStyle.filled:
      case ButtonStyle.gradient:
      default:
        return Colors.white;
    }
  }
}

// Önceden tanımlanmış button türleri
class ModernPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool fullWidth;

  const ModernPrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassmorphicButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      style: ButtonStyle.gradient,
      fullWidth: fullWidth,
      gradientColors: Constants.primaryGradient,
    );
  }
}

class ModernSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool fullWidth;

  const ModernSecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassmorphicButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      style: ButtonStyle.outlined,
      fullWidth: fullWidth,
      backgroundColor: AppTheme.primaryColor,
    );
  }
}

class ModernGlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool fullWidth;

  const ModernGlassButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassmorphicButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      style: ButtonStyle.glassmorphic,
      fullWidth: fullWidth,
    );
  }
}

class ModernNeumorphicButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool fullWidth;

  const ModernNeumorphicButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassmorphicButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      style: ButtonStyle.neumorphic,
      fullWidth: fullWidth,
    );
  }
}
