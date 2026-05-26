import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../providers/wishlist_provider.dart';
import '../models/models.dart';
import '../screens/products/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final wl = context.watch<WishlistProvider>();
    final fav = wl.isWishlisted(product.id);
    final imageUrl = product.images.isNotEmpty ? product.images[0] : null;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _ProductImage(imageUrl: imageUrl, height: 140),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => wl.toggleWishlist(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: fav ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (product.isOnSale && product.originalPrice != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${product.discountPercentage.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  RatingBarIndicator(
                    rating: product.rating,
                    itemSize: 12,
                    itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (product.originalPrice != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '₹${product.originalPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable image widget with shimmer-style loading and clear error state.
/// Handles null/empty URL gracefully without crashing.
class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double? width;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return _ProductImage(imageUrl: imageUrl, height: height, width: width, fit: fit);
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double? width;
  final BoxFit fit;

  const _ProductImage({
    required this.imageUrl,
    required this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _placeholder(height, width);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      height: height,
      width: width ?? double.infinity,
      fit: fit,
      // Animated shimmer-style loading
      placeholder: (_, __) => _loadingShimmer(height, width),
      errorWidget: (_, url, error) {
        debugPrint('Image load failed: $url — $error');
        return _errorPlaceholder(height, width);
      },
    );
  }

  Widget _loadingShimmer(double h, double? w) {
    return Container(
      height: h,
      width: w ?? double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(double h, double? w) {
    return Container(
      height: h,
      width: w ?? double.infinity,
      color: Colors.grey[100],
      child: Icon(Icons.image_outlined, size: 40, color: Colors.grey[400]),
    );
  }

  Widget _errorPlaceholder(double h, double? w) {
    return Container(
      height: h,
      width: w ?? double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 36, color: Colors.grey[400]),
          const SizedBox(height: 4),
          Text(
            'Image unavailable',
            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}