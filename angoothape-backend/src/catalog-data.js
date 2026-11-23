export const banks = [
  { id: 'sbi', name: 'State Bank of India', short: 'SBI', color: 0xff1d4f91, popular: true, ifscPrefix: 'SBIN' },
  { id: 'pnb', name: 'Punjab National Bank', short: 'PNB', color: 0xffa3195b, popular: true, ifscPrefix: 'PUNB' },
  { id: 'bob', name: 'Bank of Baroda', short: 'BoB', color: 0xffe2611f, popular: true, ifscPrefix: 'BARB' },
  { id: 'boi', name: 'Bank of India', short: 'BoI', color: 0xff1b6fb6, popular: true, ifscPrefix: 'BKID' },
  { id: 'ubi', name: 'Union Bank of India', short: 'Union', color: 0xffc8102e, popular: true, ifscPrefix: 'UBIN' },
  { id: 'cnb', name: 'Canara Bank', short: 'Canara', color: 0xff0071bc, popular: true, ifscPrefix: 'CNRB' },
  { id: 'cbi', name: 'Central Bank of India', short: 'Central', color: 0xffb22234, popular: true, ifscPrefix: 'CBIN' },
  { id: 'ib', name: 'Indian Bank', short: 'Indian', color: 0xff1c3f94, popular: true, ifscPrefix: 'IDIB' },
  { id: 'bom', name: 'Bank of Maharashtra', short: 'BoM', color: 0xff2b5da8, popular: false, ifscPrefix: null },
  { id: 'iob', name: 'Indian Overseas Bank', short: 'IOB', color: 0xff2c3e8f, popular: false, ifscPrefix: null },
  { id: 'uco', name: 'UCO Bank', short: 'UCO', color: 0xff1f5aa6, popular: false, ifscPrefix: null },
  { id: 'psb', name: 'Punjab & Sind Bank', short: 'P&S', color: 0xff2e7d32, popular: false, ifscPrefix: null },
  { id: 'hdfc', name: 'HDFC Bank', short: 'HDFC', color: 0xff004c8f, popular: false, ifscPrefix: 'HDFC' },
  { id: 'icici', name: 'ICICI Bank', short: 'ICICI', color: 0xffae282e, popular: false, ifscPrefix: 'ICIC' },
  { id: 'axis', name: 'Axis Bank', short: 'Axis', color: 0xff97144d, popular: false, ifscPrefix: 'UTIB' },
  { id: 'kotak', name: 'Kotak Mahindra Bank', short: 'Kotak', color: 0xffed1c24, popular: false, ifscPrefix: 'KKBK' },
  { id: 'idbi', name: 'IDBI Bank', short: 'IDBI', color: 0xff00836c, popular: false, ifscPrefix: null },
  { id: 'ippb', name: 'India Post Payments Bank', short: 'IPPB', color: 0xffc1272d, popular: false, ifscPrefix: null },
  { id: 'airtel', name: 'Airtel Payments Bank', short: 'Airtel', color: 0xffe40000, popular: false, ifscPrefix: null },
  { id: 'fino', name: 'Fino Payments Bank', short: 'Fino', color: 0xff5a2d82, popular: false, ifscPrefix: null },
  { id: 'bupb', name: 'Baroda UP Bank', short: 'BUPB', color: 0xffe2611f, popular: false, ifscPrefix: null },
  { id: 'aryb', name: 'Aryavart Bank', short: 'Aryavart', color: 0xff00796b, popular: false, ifscPrefix: null },
  { id: 'pupgb', name: 'Prathama UP Gramin Bank', short: 'Prathama', color: 0xff6a1b9a, popular: false, ifscPrefix: null },
  { id: 'federal', name: 'Federal Bank', short: 'Federal', color: 0xff1a3f7a, popular: false, ifscPrefix: null },
  { id: 'indus', name: 'IndusInd Bank', short: 'IndusInd', color: 0xff8c1d40, popular: false, ifscPrefix: null },
  { id: 'yes', name: 'Yes Bank', short: 'Yes', color: 0xff0047ab, popular: false, ifscPrefix: null },
];

export const faqs = {
  en: [
    [
      'The transaction is pending. What should I do?',
      "Don't give cash and don't start another withdrawal for the same customer. Open the transaction and tap Check status. Most pending transactions resolve within a few minutes. If it still shows pending after 30 minutes, raise a support request from the transaction.",
    ],
    [
      'Money was debited from the customer but the transaction failed',
      "Failed transactions are usually reversed to the customer's account automatically by their bank. Share the reference number with the customer and raise a support request so we can track it.",
    ],
    [
      'Fingerprint keeps failing',
      "Clean the scanner glass and the customer's finger. Ask them to press flat without moving. Try a different finger. If the device shows an error, open Device → Troubleshooting.",
    ],
    [
      'When does my AEPS balance reach my bank?',
      'Settlement timing depends on the partner bank and is not confirmed yet. You can see every settlement and its status in Wallet → Settlements.',
    ],
  ],
  hi: [
    [
      'लेन-देन पेंडिंग है। क्या करूँ?',
      'नकद न दें और उसी ग्राहक के लिए दूसरी निकासी शुरू न करें। लेन-देन खोलें और स्थिति जाँचें दबाएँ। ज़्यादातर पेंडिंग लेन-देन कुछ मिनटों में पूरे हो जाते हैं। 30 मिनट बाद भी पेंडिंग हो तो लेन-देन से सहायता अनुरोध करें।',
    ],
    [
      'ग्राहक के खाते से पैसा कटा पर लेन-देन असफल हुआ',
      'असफल लेन-देन में पैसा आमतौर पर बैंक अपने-आप लौटा देता है। ग्राहक को रेफ़रेंस नंबर दें और सहायता अनुरोध करें ताकि हम ट्रैक कर सकें।',
    ],
    [
      'फ़िंगरप्रिंट बार-बार असफल हो रहा है',
      'स्कैनर का शीशा और ग्राहक की उंगली साफ़ करें। सीधा दबाकर स्थिर रखने को कहें। दूसरी उंगली आज़माएँ। डिवाइस पर एरर दिखे तो डिवाइस → समस्या समाधान खोलें।',
    ],
    [
      'मेरा AEPS बैलेंस बैंक में कब आएगा?',
      'सेटलमेंट का समय पार्टनर बैंक पर निर्भर है और अभी तय नहीं है। हर सेटलमेंट और उसकी स्थिति वॉलेट → सेटलमेंट में देखें।',
    ],
  ],
};

export const issues = {
  en: [
    'Cash not given / customer dispute',
    'Customer debited but transaction failed',
    'Pending transaction',
    'Receipt or SMS issue',
    'Device issue',
    'Other',
  ],
  hi: [
    'नकद नहीं दिया / ग्राहक विवाद',
    'पैसा कटा पर लेन-देन असफल',
    'पेंडिंग लेन-देन',
    'रसीद या SMS की समस्या',
    'डिवाइस की समस्या',
    'अन्य',
  ],
};

export const futureServices = {
  en: [
    ['atm', 'Micro ATM'],
    ['send', 'Money transfer'],
    ['bill', 'Bill payments'],
    ['recharge', 'Recharge'],
    ['pan', 'PAN services'],
    ['shield', 'Insurance'],
    ['cash', 'Cash collection'],
    ['topup', 'Wallet top-up'],
  ],
  hi: [
    ['atm', 'माइक्रो एटीएम'],
    ['send', 'मनी ट्रांसफ़र'],
    ['bill', 'बिल भुगतान'],
    ['recharge', 'रिचार्ज'],
    ['pan', 'PAN सेवा'],
    ['shield', 'बीमा'],
    ['cash', 'कैश कलेक्शन'],
    ['topup', 'वॉलेट टॉप-अप'],
  ],
};

export const miniTemplate = [
  { daysAgo: 1, label: 'UPI/ Kirana', amount: -340 },
  { daysAgo: 2, label: 'NEFT CR Salary', amount: 8200 },
  { daysAgo: 3, label: 'ATM WDL', amount: -2000 },
  { daysAgo: 5, label: 'PM-KISAN CR', amount: 2000 },
  { daysAgo: 6, label: 'AEPS WDL', amount: -1000 },
];
