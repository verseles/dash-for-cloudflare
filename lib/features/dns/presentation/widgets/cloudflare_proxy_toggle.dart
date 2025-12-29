import 'package:flutter/material.dart';

/// Cloudflare proxy toggle switch
class CloudflareProxyToggle extends StatelessWidget {
  final bool value;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  const CloudflareProxyToggle({
    super.key,
    required this.value,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Tooltip(
      message: value ? 'Proxied through Cloudflare' : 'DNS only',
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: value
                ? const Color(0xFFF38020).withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud,
                size: 16,
                color: value ? const Color(0xFFF38020) : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                value ? 'Proxied' : 'DNS only',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: value ? const Color(0xFFF38020) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
