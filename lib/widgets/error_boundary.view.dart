import 'package:flutter/material.dart';

/// A widget that catches errors in its child widget tree and displays
/// a custom error UI instead of the red error screen.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? errorBuilder;
  final void Function(FlutterErrorDetails)? onError;
  final bool showErrorInDebug;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
    this.onError,
    this.showErrorInDebug = true,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
  }

  void _handleError(FlutterErrorDetails details) {
    if (mounted) {
      setState(() {
        _errorDetails = details;
      });
      widget.onError?.call(details);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      // Show custom error widget
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_errorDetails!);
      }

      // Default error UI
      return _DefaultErrorWidget(
        errorDetails: _errorDetails!,
        showErrorInDebug: widget.showErrorInDebug,
        onRetry: () {
          setState(() {
            _errorDetails = null;
          });
        },
      );
    }

    // Wrap child with error handling
    return _ErrorCatcher(
      onError: _handleError,
      child: widget.child,
    );
  }
}

/// Internal widget that catches errors in its child widget tree
class _ErrorCatcher extends StatefulWidget {
  final Widget child;
  final void Function(FlutterErrorDetails) onError;

  const _ErrorCatcher({
    required this.child,
    required this.onError,
  });

  @override
  State<_ErrorCatcher> createState() => _ErrorCatcherState();
}

class _ErrorCatcherState extends State<_ErrorCatcher> {
  ErrorWidgetBuilder? _previousErrorWidgetBuilder;

  @override
  void initState() {
    super.initState();
    // Store the previous error widget builder
    _previousErrorWidgetBuilder = ErrorWidget.builder;
    
    // Override error widget builder for this subtree
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Handle the error in the parent ErrorBoundary
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onError(details);
      });
      
      // Return a placeholder while the error is being handled
      return const SizedBox.shrink();
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    // Restore the previous error widget builder
    if (_previousErrorWidgetBuilder != null) {
      ErrorWidget.builder = _previousErrorWidgetBuilder!;
    }
    super.dispose();
  }
}

/// Default error widget shown when no custom errorBuilder is provided
class _DefaultErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;
  final bool showErrorInDebug;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({
    required this.errorDetails,
    required this.showErrorInDebug,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 60),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We encountered an unexpected error.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              if (showErrorInDebug) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...[
                          Text(
                            'Error:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            errorDetails.exception.toString(),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (errorDetails.stack.toString().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Stack trace:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            errorDetails.stack.toString(),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                            ),
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
