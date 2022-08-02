import 'package:dio/dio.dart';

class DataModel {
  final String answer;
  final String giflink;
  DataModel({
    required this.answer,
    required this.giflink,
  });

  factory DataModel.fromJson(dynamic data) {
    return DataModel(
      answer: data['answer'],
      giflink: data['image'],
    );
  }
}

class HomeRepo {
  static final Dio _dio = Dio();

  static Future<DataModel> getData() async {
    final res = await _dio.get('https://yesno.wtf/api');
    return DataModel.fromJson(res.data);
  }
}
