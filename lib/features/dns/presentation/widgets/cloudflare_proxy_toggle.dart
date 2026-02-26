import 'package:flutter/material.dart';

/// Cloudflare proxy toggle switch with smooth transitions
class CloudflareProxyToggle extends StatelessWidget {
  const CloudflareProxyToggle({
    super.key,
    required this.value,
    required this.isLoading,
    required this.onChanged,
  });

  final bool value;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: value ? 'Proxied through Cloudflare' : 'DNS only',
      child: GestureDetector(
        onTap: isLoading ? null : () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: value
                ? const Color(0xFFF38020).withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    key: ValueKey('proxy_$value'),
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
      ),
    );
  }
}
