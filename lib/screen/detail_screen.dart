import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_model.dart';
import '../service/api_service.dart';

class DetailScreen extends StatefulWidget {
  final String mealId;

  const DetailScreen({super.key, required this.mealId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Meal? _meal;
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final meal = await ApiService.fetchMealDetail(widget.mealId);

      setState(() {
        _meal = meal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_meal == null) return;

    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      _showSnackBar('Ditambahkan ke favorit');
    } else {
      _showSnackBar('Dihapus dari favorit');
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      if (mounted) {
        _showSnackBar(
          'Tidak dapat membuka URL',
          isError: true,
        );
      }
    }
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Makanan'),
        actions: [
          if (_meal != null)
            IconButton(
              icon: Icon(
                _isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color:
                    _isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });

                          _loadDetail();
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _meal == null
                  ? const Center(
                      child: Text(
                        'Data tidak ditemukan',
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          CachedNetworkImage(
                            imageUrl:
                                _meal!.strMealThumb,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) =>
                                    Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child:
                                    CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget:
                                (context, url, error) =>
                                    Container(
                              color: Colors.grey[300],
                              child:
                                  const Icon(Icons.error),
                            ),
                          ),

                          Padding(
                            padding:
                                const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  _meal!.strMeal,
                                  style:
                                      const TextStyle(
                                    fontSize: 24,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Colors.black87,
                                  ),
                                ),

                                const SizedBox(
                                    height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            'Kategori',
                                            style:
                                                TextStyle(
                                              fontSize:
                                                  12,
                                              color: Colors
                                                      .grey[
                                                  600],
                                              fontWeight:
                                                  FontWeight
                                                      .w500,
                                            ),
                                          ),

                                          const SizedBox(
                                              height:
                                                  4),

                                          Container(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal:
                                                  12,
                                              vertical: 6,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8),
                                            ),
                                            child: Text(
                                              _meal!.strCategory ??
                                                  'N/A',
                                              style:
                                                  const TextStyle(
                                                fontSize:
                                                    12,
                                                color: Colors
                                                    .black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(
                                        width: 16),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            'Asal Negara',
                                            style:
                                                TextStyle(
                                              fontSize:
                                                  12,
                                              color: Colors
                                                      .grey[
                                                  600],
                                              fontWeight:
                                                  FontWeight
                                                      .w500,
                                            ),
                                          ),

                                          const SizedBox(
                                              height:
                                                  4),

                                          Container(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal:
                                                  12,
                                              vertical: 6,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8),
                                            ),
                                            child: Text(
                                              _meal!.strArea ??
                                                  'N/A',
                                              style:
                                                  const TextStyle(
                                                fontSize:
                                                    12,
                                                color: Colors
                                                    .black,
                                                fontWeight:
                                                    FontWeight
                                                        .w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                    height: 24),

                                const Text(
                                  'Cara Membuat',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(
                                    height: 8),

                                Container(
                                  padding:
                                      const EdgeInsets
                                          .all(12),
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        Colors.grey[50],
                                    borderRadius:
                                        BorderRadius
                                            .circular(12),
                                    border: Border.all(
                                      color: Colors
                                          .grey[200]!,
                                    ),
                                  ),
                                  child: Text(
                                    _meal!
                                            .strInstructions ??
                                        'N/A',
                                    style:
                                        const TextStyle(
                                      fontSize: 13,
                                      color:
                                          Colors.black87,
                                      height: 1.6,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                    height: 24),

                                if (_meal!.strSource !=
                                        null &&
                                    _meal!
                                        .strSource!
                                        .isNotEmpty)
                                  SizedBox(
                                    width:
                                        double.infinity,
                                    height: 50,
                                    child:
                                        ElevatedButton
                                            .icon(
                                      icon: const Icon(
                                        Icons
                                            .open_in_browser,
                                      ),
                                      label: const Text(
                                        'Kunjungi Sumber Resep',
                                      ),
                                      style:
                                          ElevatedButton
                                              .styleFrom(
                                        backgroundColor:
                                            Colors.blue,
                                        foregroundColor:
                                            Colors.white,
                                      ),
                                      onPressed: () =>
                                          _launchUrl(
                                        _meal!
                                            .strSource!,
                                      ),
                                    ),
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