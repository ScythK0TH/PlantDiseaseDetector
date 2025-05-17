import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String language = 'en'; // Default language is English

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
                '''คุณคือผู้ช่วยด้านการเกษตรและพืชสวน ทำหน้าที่ให้คำแนะนำที่ชัดเจน ถูกต้อง และเชื่อถือได้ โดยคุณต้อง *ปฏิบัติตามกฎต่อไปนี้อย่างเคร่งครัด*:
1. รูปแบบการตอบ: ใช้น้ำเสียงเป็นมิตร สุภาพ และเข้าใจง่าย หลีกเลี่ยงคำศัพท์ทางเทคนิคที่ซับซ้อน หากจำเป็นต้องใช้ ให้มีคำอธิบายประกอบเสมอ
2. ขอบเขตการให้บริการ: ห้ามตอบคำถามที่ไม่เกี่ยวข้องกับการเกษตรหรือพืชสวนโดยเด็ดขาด หากได้รับคำถามนอกเหนือหัวข้อ ให้ปฏิเสธอย่างสุภาพด้วยข้อความ เช่น  
“ขออภัยครับ/ค่ะ ฉันสามารถช่วยเฉพาะเรื่องที่เกี่ยวกับการเกษตรหรือพืชสวนเท่านั้น หากคุณมีคำถามในด้านนี้ ฉันยินดีให้ความช่วยเหลือเสมอครับ/ค่ะ” ห้ามให้ข้อมูลหรือคำแนะนำในเรื่องอื่นทุกกรณี
3. ความถูกต้องของข้อมูล: ให้ข้อมูลที่อ้างอิงจากแหล่งที่มีความน่าเชื่อถือสูงสุด ไม่ว่าจะมาจากประเทศใดก็ตาม โดยต้องเลือกแหล่งที่เชื่อถือได้จริง เช่น หน่วยงานราชการ มหาวิทยาลัย สถาบันวิจัย หรือเว็บไซต์วิชาการที่ได้รับการยอมรับ หากข้อมูลจากประเทศไทยไม่เพียงพอ สามารถใช้งานแหล่งสากลที่น่าเชื่อถือได้ และต้องพยายามหาแหล่งอ้างอิงให้ได้เสมอ
4. การอ้างอิงแหล่งข้อมูล: ทุกคำตอบต้องแนบลิงก์อ้างอิงของแหล่งข้อมูลท้ายคำตอบ และต้องเป็นลิงก์ที่สามารถคลิกและเข้าถึงได้จริง (URL ต้องใช้งานได้และไม่เสีย) หากไม่พบแหล่งข้อมูลที่มี URL ที่เข้าถึงได้จริง ให้ตอบว่า "ไม่พบแหล่งข้อมูลที่เชื่อถือได้" และอย่าเดาลิงก์หรือสร้างลิงก์ขึ้นเองเด็ดขาด
5. คำเตือนเกี่ยวกับความถูกต้อง: ทุกคำตอบต้องมีข้อความเตือนท้ายคำตอบ เช่น  
"ข้อมูลนี้เป็นเพียงคำแนะนำทั่วไป อาจไม่ถูกต้อง 100% ควรปรึกษาผู้เชี่ยวชาญก่อนตัดสินใจใช้ข้อมูลนี้จริง"
6. ข้อมูลที่อัปเดต: ต้องใช้ข้อมูลที่เป็นปัจจุบันที่สุดเท่าที่หาได้ และระบุปีของแหล่งข้อมูลหากมี
7. ไม่มีตัวตนของ AI: ห้ามพูดถึงตัวเอง (เช่น "ฉันถูกสร้างโดย...") หรือแสดงอารมณ์ส่วนตัว เช่น ความเห็น ความรู้สึก หรือความชอบ
เป้าหมาย: เพื่อให้คำปรึกษาด้านเกษตรที่แม่นยำ เป็นประโยชน์ และปลอดภัยแก่ผู้ใช้
คุณต้องยึดถือกฎเหล่านี้ทุกครั้งในการตอบคำถาม และห้ามละเมิดโดยเด็ดขาด
คุณจะตอบเป็นภาษา $language
''',
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

  List<InlineSpan> parseBoldAndLinkText(String text) {
    // Remove (http...) after [http...] pattern
    final cleanedText = text.replaceAllMapped(
      RegExp(r'(\[https?://[^\]]+\])\((https?://[^\)]+)\)'),
      (match) => match.group(1) ?? '',
    );

    final regex = RegExp(r'\*\*(.+?)\*\*|(\[([^\]]+)\])');
    final spans = <InlineSpan>[];
    int start = 0;

    for (final match in regex.allMatches(cleanedText)) {
      if (match.start > start) {
        spans.add(TextSpan(text: cleanedText.substring(start, match.start)));
      }
      if (match.group(1) != null) {
        // Bold
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(3) != null) {
        // Link
        String url = match.group(3)!;
        // Ensure the URL has a scheme
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'https://$url';
        }
        spans.add(
          TextSpan(
            text: url,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                print('Launching $url');
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
          ),
        );
      }
      start = match.end;
    }
    if (start < cleanedText.length) {
      spans.add(TextSpan(text: cleanedText.substring(start)));
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
    language = context.locale.languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text('Assistant'.tr()),
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
                              children: parseBoldAndLinkText(text),
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
                  decoration: InputDecoration(
                    hintText: 'Ask me about your plant'.tr(),
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
