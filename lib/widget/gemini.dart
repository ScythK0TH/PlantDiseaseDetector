import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:project_pdd/services/database.dart';
import 'package:project_pdd/ui/styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  String language = 'en'; // Default language is English

  // MongoDB connection string and collection name
  final String cacheCollection = 'gemini_cache';

  List<Map<String, dynamic>> chatHistory = [];

  final ScrollController _scrollController = ScrollController();

  Future<void> saveCache(String userId, String plantId,
      List<Map<String, dynamic>> chatHistory) async {
    final db = MongoService();
    final col = db.assistantCollection;
    await col!.updateOne(
      mongo.where.eq('userId', userId).eq('plantId', plantId),
      mongo.modify
          .set('chatHistory', chatHistory)
          .set('updatedAt', DateTime.now().toIso8601String()),
      upsert: true,
    );
  }

  Future<List<Map<String, dynamic>>?> fetchCache(
      String userId, String plantId) async {
    final db = MongoService();
    final col = db.assistantCollection;
    final doc = await col!.findOne({'userId': userId, 'plantId': plantId});
    if (doc?['chatHistory'] != null) {
      return List<Map<String, dynamic>>.from(
        (doc!['chatHistory'] as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }
    return null;
  }

  Future<void> loadOrFetchResponse() async {
    setState(() {
      responseText = null;
    });
    final userId = widget.userId;
    final plantId = widget.plant['_id'].toString();
    final cachedHistory = await fetchCache(userId, plantId);
    if (cachedHistory != null && cachedHistory.isNotEmpty) {
      setState(() {
        chatHistory = cachedHistory;
        responseText = chatHistory.lastWhere((msg) => msg['role'] == 'model',
            orElse: () => {
                  'parts': [
                    {'text': ''}
                  ]
                })['parts'][0]['text'];
      });
    } else {
      final initialPrompt = "Disease".tr() + " ${widget.plant['predict']}";
      chatHistory.clear();
      await getGeminiResponse(
        initialPrompt,
        withImageAndPredict: true,
        cacheUserId: userId,
        cachePlantId: plantId,
      );
    }
  }

  Future<void> getGeminiResponse(String userPrompt,
      {bool withImageAndPredict = false,
      String? cacheUserId,
      String? cachePlantId}) async {
    // Add user message to history
    setState(() {
      chatHistory.add({
        "role": "user",
        "parts": [
          {"text": userPrompt}
        ]
      });
      chatHistory.add({
        "role": "loading",
        "parts": [
          {"text": "Thinking...".tr()} // "Responding..."
        ]
      });
      responseText = null;
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
            "text":
                "ข้อมูลการทำนาย: ${widget.plant['predict'] ?? 'ไม่มีข้อมูล'}"
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
      // Add all previous messages, but filter out 'loading'
      // This will prevent "role": "loading" from being sent to Gemini, and the error will be resolved.
      contents.addAll(chatHistory
          .where((msg) => msg['role'] == 'user' || msg['role'] == 'model'));
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
      final text =
          (data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '')
              .trim();

      if (!mounted) return;

      setState(() {
        // Remove loading message
        chatHistory.removeWhere((msg) => msg['role'] == 'loading');
        // Add assistant's reply
        chatHistory.add({
          "role": "model",
          "parts": [
            {"text": text}
          ]
        });
        responseText = text;
      });
      // Save to cache if needed
      if (cacheUserId != null && cachePlantId != null) {
        await saveCache(cacheUserId, cachePlantId, chatHistory);
      }
    } else {
      setState(() {
        chatHistory.removeWhere((msg) => msg['role'] == 'loading');
        responseText =
            "เกิดข้อผิดพลาด: ${response.statusCode}\n${response.body}";
      });
      log('Gemini API error: ${response.statusCode} - ${response.body}');
    }

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              AppTheme.isDarkMode(context) ? Brightness.light : Brightness.dark,
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Expanded(
                  child: Text('Assistant'.tr(),
                      style: AppTheme.largeTitle(context),
                      textAlign: TextAlign.left)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.themedBgIconColor(context),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                      onPressed: () async {
                        chatHistory.clear();
                        final initialPrompt =
                            "Disease".tr() + " ${widget.plant['predict']}";
                        await getGeminiResponse(
                          initialPrompt,
                          withImageAndPredict: true,
                          cacheUserId: widget.userId,
                          cachePlantId: widget.plant['_id'].toString(),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.themedBgIconColor(context),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppTheme.themedIconColor(context),
                        size: 24.0,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: true,
        left: true,
        right: true,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(
              top: 8.0, left: 20.0, right: 20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: chatHistory.length,
                        itemBuilder: (context, index) {
                          final msg = chatHistory[index];
                          final isUser = msg['role'] == 'user';
                          final isGemini = msg['role'] == 'model';
                          final isLoadingMsg = msg['role'] == 'loading';
                          final text = msg['parts'][0]['text'] ?? '';
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              // ไม่ต้องใช้ Row ครอบ
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isGemini || isLoadingMsg) ...[
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                        shape: BoxShape.circle,
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        child: Icon(Icons.auto_awesome,
                                            color: AppTheme.themedIconColor(
                                                context),
                                            size: 16),
                                        radius: 16,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isUser
                                            ? null
                                            : AppTheme.themedBgIconColor(
                                                context),
                                        gradient: isUser
                                            ? AppTheme.secondaryGradient
                                            : null,
                                        borderRadius: BorderRadius.only(
                                          topLeft: isUser
                                              ? const Radius.circular(24)
                                              : const Radius.circular(0),
                                          topRight: isUser
                                              ? const Radius.circular(0)
                                              : const Radius.circular(24),
                                          bottomLeft: const Radius.circular(24),
                                          bottomRight:
                                              const Radius.circular(24),
                                        ),
                                      ),
                                      child: isLoadingMsg
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color:
                                                        AppTheme.primaryColor,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Text(text),
                                              ],
                                            )
                                          : RichText(
                                              text: TextSpan(
                                                style:
                                                    DefaultTextStyle.of(context)
                                                        .style,
                                                children:
                                                    parseBoldAndLinkText(text),
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    minimum:
                        const EdgeInsets.only(bottom: 12),
                    top: false,
                    left: false,
                    right: false,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(36),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.themedBgIconColor(context),
                            borderRadius: BorderRadius.circular(36),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  decoration: InputDecoration(
                                    hintText: 'Ask me about your plant'.tr(),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 8.0),
                                  ),
                                  minLines: 1,
                                  maxLines: 4,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.send),
                                  color: Colors
                                      .white, // สีไอคอนให้ตัดกับพื้นหลัง gradient
                                  onPressed: () {
                                    final text = _controller.text.trim();
                                    if (text.isNotEmpty) {
                                      getGeminiResponse(
                                        text,
                                        withImageAndPredict: false,
                                        cacheUserId: widget.userId,
                                        cachePlantId:
                                            widget.plant['_id'].toString(),
                                      );
                                      _controller.clear();
                                      // Scroll ลงล่างสุดทันทีหลัง user ส่งข้อความ
                                      _scrollToBottom();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
