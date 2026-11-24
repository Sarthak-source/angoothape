class ReasonCopy {
  const ReasonCopy({
    required this.en,
    required this.hi,
    required this.nextEn,
    required this.nextHi,
  });
  final String en;
  final String hi;
  final String nextEn;
  final String nextHi;
  String text(String lang) => lang == 'hi' ? hi : en;
  String next(String lang) => lang == 'hi' ? nextHi : nextEn;
}

final reasons = <String, ReasonCopy>{
  'insufficient': ReasonCopy(
    en: "Customer's account has insufficient balance.",
    hi: 'ग्राहक के खाते में पर्याप्त बैलेंस नहीं है।',
    nextEn: 'Ask the customer to try a smaller amount or check their balance.',
    nextHi: 'ग्राहक से कम राशि आज़माने या बैलेंस जाँचने को कहें।',
  ),
  'bio': ReasonCopy(
    en: "Fingerprint didn't match Aadhaar records.",
    hi: 'फ़िंगरप्रिंट आधार रिकॉर्ड से मेल नहीं खाया।',
    nextEn: 'Try another finger. If it keeps failing, the customer may need to update biometrics at an Aadhaar centre.',
    nextHi: 'दूसरी उंगली आज़माएँ। बार-बार असफल हो तो ग्राहक को आधार केंद्र पर बायोमेट्रिक अपडेट करवाना पड़ सकता है।',
  ),
  'bankdown': ReasonCopy(
    en: "Customer's bank is not responding right now.",
    hi: 'ग्राहक का बैंक अभी जवाब नहीं दे रहा।',
    nextEn: 'Try again in a few minutes or use another bank account if the customer has one.',
    nextHi: 'कुछ मिनट बाद फिर कोशिश करें या ग्राहक का दूसरा बैंक खाता इस्तेमाल करें।',
  ),
  'timeout': ReasonCopy(
    en: 'Bank did not confirm the transaction. It was marked failed.',
    hi: 'बैंक ने लेन-देन की पुष्टि नहीं की। इसे असफल माना गया।',
    nextEn: 'If the customer was debited, the bank reverses it automatically. Raise a support request to track it.',
    nextHi: 'अगर पैसा कटा है तो बैंक अपने-आप लौटा देगा। ट्रैक करने के लिए सहायता अनुरोध करें।',
  ),
};

void applyReasons(Map<String, ReasonCopy> next) {
  if (next.isEmpty) return;
  reasons
    ..clear()
    ..addAll(next);
}
