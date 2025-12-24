import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;

  MongoService._internal();

  Db? _db;
  bool get isConnected => _db?.isConnected ?? false;
  DbCollection? get plantCollection => _db?.collection('plants');
  DbCollection? get userCollection => _db?.collection('users');
  DbCollection? get assistantCollection => _db?.collection('gemini_cache');

  final String _mongoUrl = "url"; // input mongodb url here

  Future<void> connect() async {
    if (_db == null || !_db!.isConnected) {
      try {
        _db = await Db.create(_mongoUrl); 
        await _db!.open();
      } catch (e) {
        print('MongoDB connection error: $e');
        rethrow;
      }
    }
  }

  Future<void> disconnect() async {
    if (_db != null && _db!.isConnected) {
      try {
        await _db!.close();
      } catch (e) {
        print('MongoDB disconnection error: $e');
      }
    }
  }

  Future<void> dispose() async {
    await disconnect();
    _db = null;
  }
}
