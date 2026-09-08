import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/gallery/data/datasource/gallery_datasource.dart';
import 'package:demo/features/gallery/data/model/gallery_model.dart';
import 'package:demo/features/gallery/domain/entities/gallery_entity.dart';
import 'package:demo/features/gallery/domain/repository/gallery_repository.dart';
import 'package:dio/dio.dart';

class GalleryDatasourceImpl implements GalleryRepository {
  final GalleryDatasource galleryDatasource;

  GalleryDatasourceImpl(this.galleryDatasource);
  @override
  Future<List<GalleryEntity>> getGalleryDetails({required String type}) {
    return galleryDatasource.getGalleryData(type: type);
  }
}
