import 'package:intl/intl.dart';

class GemmaPromptBuilder {
  static String buildExtractionPrompt({
    required String userSpeech,
    required String currentLanguage,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final dayOfWeek = DateFormat('EEEE').format(now);
    final tomorrowDate = DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 1)));

    return '''
You are a Gujarati business instruction parser AI for Indian small businesses (traders, shopkeepers, suppliers).
Your task is to parse spoken business instructions in Gujarati, Gujlish (Gujarati-English mixed), Hinglish, or English into structured JSON.

CURRENT CONTEXT:
- Current Date: $formattedDate ($dayOfWeek)
- Preferred Output Language: $currentLanguage

GUJARATI VOCABULARY DICTIONARY:
- "aaje" / "આજે" = today ($formattedDate)
- "kale" / "કાલે" = tomorrow ($tomorrowDate)
- "parso" / "પરમ દિવસે" = day after tomorrow
- "mokalvanu" / "મોકલવાનું" / "mokalvana" = deliver / send
- "paisa" / "રૂપિયા" / "rupiya" = money / amount
- "baki" / "બાકી" / "payment" = pending payment
- "yad karavjo" / "યાદ કરાવજો" = payment reminder
- "phone karjo" / "vaat karjo" = customer follow-up / call
- "order" / "maal" / "box" / "piece" / "kilo" = goods / item quantity

FIELDS TO EXTRACT:
- "type": MUST be one of: "task", "order", "payment_reminder", "delivery", "customer_followup", "other"
- "customer_name": Name of person/customer mentioned (e.g. "Ramesh bhai", "Manoj bhai"), or null if absent. Preserve exact name spelling.
- "task": Action/work description (e.g. "Deliver 20 boxes", "Send goods"), or null.
- "product": Product or item name (e.g. "box", "cotton", "shirts"), or null.
- "quantity": Numeric quantity (e.g. 20), or null.
- "quantity_unit": Unit string (e.g. "box", "piece", "kilo"), or null.
- "amount": Numeric payment amount in INR (e.g. 5000), or null.
- "date": Relative date string or YYYY-MM-DD (e.g. "tomorrow", "$tomorrowDate", "$formattedDate"), or null.
- "time": Time of day if specified, or null.
- "payment_reminder": true if payment reminder requested or money pending, otherwise false.
- "delivery_instruction": Specific delivery notes if any, or null.
- "follow_up_instruction": Specific follow-up or call action if any, or null.
- "notes": Any extra context or remarks, or null.
- "generated_message": Polite WhatsApp message for customer in $currentLanguage.

CRITICAL INSTRUCTIONS:
1. Return ONLY pure raw JSON object.
2. DO NOT use Markdown formatting or ```json code blocks.
3. DO NOT output any introductory text, greetings, explanations, or conclusions.
4. If a field is missing in input, set it to null instead of guessing.

USER INSTRUCTION:
"$userSpeech"

OUTPUT JSON:
''';
  }

  static String buildRegenerationPrompt({
    required String originalInstruction,
    required String customerName,
    required double? amount,
    required String? action,
    required String targetLanguage,
  }) {
    return '''
You are VyaparMitra AI. Generate a polite, business WhatsApp message in language '$targetLanguage' (gu=Gujarati, hi=Hindi, en=English).
Customer: ${customerName.isEmpty ? 'Customer' : customerName}
Action: ${action ?? 'Order/Work'}
Amount: ${amount != null ? '₹$amount' : 'None'}
Original Instruction: "$originalInstruction"

Return ONLY the raw plain text message body. No quotes, no markdown.
''';
  }
}
