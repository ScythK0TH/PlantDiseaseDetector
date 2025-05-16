import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_pdd/constant.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'dart:developer';

class GeminiChatPage extends StatefulWidget {
  final Map<String, dynamic> plant;
  final String userId;
  const GeminiChatPage({super.key, required this.plant, required this.userId});

  @override
  State<GeminiChatPage> createState() => _GeminiChatPageState();
}

class _GeminiChatPageState extends State<GeminiChatPage> {
  final TextEditingController _controller = TextEditingController();
  String? responseText;
  bool isLoading = false;

  // MongoDB connection string and collection name
  final String mongoUri = MONGO_URL; // <-- change to your MongoDB URI
  final String cacheCollection = 'gemini_cache';

  List<Map<String, dynamic>> chatHistory = [];

  final ScrollController _scrollController = ScrollController();

  Future<void> saveCache(String userId, String plantId, List<Map<String, dynamic>> chatHistory) async {
    final db = await mongo.Db.create(mongoUri);
    await db.open();
    final col = db.collection(cacheCollection);
    await col.updateOne(
      mongo.where.eq('userId', userId).eq('plantId', plantId),
      mongo.modify
          .set('chatHistory', chatHistory)
          .set('updatedAt', DateTime.now().toIso8601String()),
      upsert: true,
    );
    await db.close();
  }

  Future<List<Map<String, dynamic>>?> fetchCache(String userId, String plantId) async {
    final db = await mongo.Db.create(mongoUri);
    await db.open();
    final col = db.collection(cacheCollection);
    final doc = await col.findOne({'userId': userId, 'plantId': plantId});
    await db.close();
    if (doc?['chatHistory'] != null) {
      return List<Map<String, dynamic>>.from(
        (doc!['chatHistory'] as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }
    return null;
  }

  Future<void> loadOrFetchResponse() async {
    setState(() {
      isLoading = true;
      responseText = null;
    });
    final userId = widget.userId;
    final plantId = widget.plant['_id'].toString();
    final cachedHistory = await fetchCache(userId, plantId);
    if (cachedHistory != null && cachedHistory.isNotEmpty) {
      setState(() {
        chatHistory = cachedHistory;
        responseText = chatHistory.lastWhere((msg) => msg['role'] == 'model', orElse: () => {'parts': [{'text': ''}]} )['parts'][0]['text'];
        isLoading = false;
      });
    } else {
      final initialPrompt = "โรค ${widget.plant['predict']}";
      chatHistory.clear();
      await getGeminiResponse(
        initialPrompt,
        withImageAndPredict: true,
        cacheUserId: userId,
        cachePlantId: plantId,
      );
    }
  }

  Future<void> getGeminiResponse(String userPrompt, {bool withImageAndPredict = false, String? cacheUserId, String? cachePlantId}) async {
    setState(() {
      isLoading = true;
      responseText = null;
    });

    // Add user message to history
    chatHistory.add({
      "role": "user",
      "parts": [
        {"text": userPrompt}
      ]
    });

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');

    // Prepare initial context if needed
    List<Map<String, dynamic>> contents = [
      {
        "role": "user",
        "parts": [
          {
            "text":
                "คุณคือผู้ช่วยที่มีความรู้เกี่ยวกับการเกษตรและพืชสวน คุณสามารถให้คำแนะนำเกี่ยวกับการปลูกพืช การดูแลพืช และการจัดการศัตรูพืชได้ โดยคุณจะต้องตอบคำถามของผู้ใช้ในลักษณะที่เป็นมิตรและให้ข้อมูลที่ถูกต้อง คุณจะไม่พูดถึงตัวเองหรือแสดงความรู้สึกส่วนตัว คุณจะต้องให้ข้อมูลที่เป็นประโยชน์และมีคุณค่าแก่ผู้ใช้เสมอ คุณจะให้คำตอบที่ชัดเจนและเข้าใจง่าย และจะไม่ใช้ศัพท์เทคนิคที่ซับซ้อนเกินไป คุณไม่อนุญาตให้ผู้ใช้ถามคำถามที่ไม่เกี่ยวข้องกับการเกษตรหรือพืชสวน และคุณจะต้องปฏิเสธคำถามเหล่านั้นอย่างสุภาพ คำถามที่ไม่เกี่ยวข้องกับการเกษตรหรือพืชสวนจะต้องได้รับการตอบกลับด้วยความสุภาพและเป็นมิตร เช่น 'ขอโทษครับ/ค่ะ ฉันไม่สามารถช่วยในเรื่องนั้นได้ แต่ถ้าคุณมีคำถามเกี่ยวกับการเกษตรหรือพืชสวน ฉันยินดีที่จะช่วยเสมอ' คุณจะต้องให้ข้อมูลที่ถูกต้องและเป็นประโยชน์แก่ผู้ใช้เสมอ จะต้องจดจำกฏการทำงานนี้และปฏิบัติตามอย่างเคร่งครัด",
          }
        ]
      }
    ];

    if (withImageAndPredict) {
      contents.add({
        "role": "user",
        "parts": [
          {
            "text": "ข้อมูลการทำนาย: ${widget.plant['predict'] ?? 'ไม่มีข้อมูล'}"
          },
          if (widget.plant['image'] != null)
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": widget.plant['image']
              }
            },
          {"text": userPrompt}
        ]
      });
    } else {
      // Add all previous messages
      contents.addAll(chatHistory);
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": contents,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = (data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '').trim();
      setState(() {
        responseText = text;
      });
      // Add assistant's reply to history
      chatHistory.add({
        "role": "model",
        "parts": [
          {"text": text}
        ]
      });
      // Save to cache if needed
      if (cacheUserId != null && cachePlantId != null) {
        await saveCache(cacheUserId, cachePlantId, chatHistory);
      }
    } else {
      setState(() {
        responseText = "เกิดข้อผิดพลาด: ${response.statusCode}\n${response.body}";
      });
      log('Gemini API error: ${response.statusCode} - ${response.body}');
    }

    setState(() {
      isLoading = false;
    });
    _scrollToBottom();
  }

  @override
  void initState() {
    super.initState();
    loadOrFetchResponse();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<InlineSpan> parseBoldText(String text) {
    final regex = RegExp(r'\*\*(.+?)\*\*');
    final spans = <InlineSpan>[];
    int start = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return spans;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: isLoading
                ? null
                : () async {
                    chatHistory.clear();
                    final initialPrompt = "โรค ${widget.plant['predict']}";
                    await getGeminiResponse(
                      initialPrompt,
                      withImageAndPredict: true,
                      cacheUserId: widget.userId,
                      cachePlantId: widget.plant['_id'].toString(),
                    );
                  },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              const SizedBox(height: 20),
              if (responseText != null)
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) {
                      final msg = chatHistory[index];
                      final isUser = msg['role'] == 'user';
                      final text = msg['parts'][0]['text'] ?? '';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: parseBoldText(text),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          margin: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'พิมพ์ข้อความ...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  minLines: 1,
                  maxLines: 4,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                color: Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                onPressed: isLoading
                    ? null
                    : () {
                        final text = _controller.text.trim();
                        if (text.isNotEmpty) {
                          getGeminiResponse(text, 
                              withImageAndPredict: false,
                              cacheUserId: widget.userId,
                              cachePlantId: widget.plant['_id'].toString());
                          _controller.clear();
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
