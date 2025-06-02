import Foundation
import UIKit

// إضافة enum لأنواع القوالب
enum TemplateType: String, CaseIterable {
    case withoutLogos = "template_with_placeholder"
    case withLogos = "template_with_placeholder_new"
    
    var displayName: String {
        switch self {
        case .withoutLogos:
            return "قالب بدون شعارات"
        case .withLogos:
            return "قالب مع شعارات"
        }
    }
    
    var description: String {
        switch self {
        case .withoutLogos:
            return "القالب العادي مع إمكانية تعديل جميع الحقول"
        case .withLogos:
            return "قالب محسن مع شعارات إضافية، حقل الجهة مقفل في التواقيع"
        }
    }
}

class FormFieldsModel: ObservableObject {
    // إعدادات تخصيص الخط واللون لـ PDF
    // يمكن تعديل هذه القيم في مستوى الكود لتغيير مظهر النص في PDF
    
    // للتبديل بين خطوط Myriad Arabic المختلفة، قم بتغيير قيمة selectedFontFamily إلى أحد الخيارات التالية:
    // "MyriadArabic-Regular"      - عادي
    // "MyriadArabic-Bold"         - عريض
    // "MyriadArabic-SemiBold"     - نصف عريض
    // "MyriadArabic-Light"        - خفيف
    
    @Published var selectedFontFamily: String = "MyriadArabic-Regular" // نوع الخط الافتراضي - خط عربي Myriad
    @Published var selectedFontSize: CGFloat = 14.0         // حجم الخط الافتراضي (أكبر قليلاً للخط العربي)
    @Published var selectedTextColor: UIColor = UIColor(red: 0x00/255.0, green: 0x75/255.0, blue: 0xbe/255.0, alpha: 1.0) // اللون الأزرق الجديد #0075be
    
    // إضافة متغير اختيار القالب
    @Published var selectedTemplate: TemplateType = .withoutLogos
    @Published var isTemplateSelected: Bool = false
    
    // خيارات عائلات الخطوط المتاحة
    // يمكن إضافة أو إزالة خطوط من هذه القائمة
    let availableFonts = [
        // خطوط Myriad Arabic العربية (الأولوية الأولى)
        "MyriadArabic-Regular",
        "MyriadArabic-Bold",
        "MyriadArabic-SemiBold",
        "MyriadArabic-Light",
        // خطوط Bahij TheSansArabic العربية (احتياطية)
        "Bahij_TheSansArabic-Plain",
        "Bahij_TheSansArabic-Light", 
        "Bahij_TheSansArabic-ExtraLight",
        "Bahij_TheSansArabic-SemiLight",
        "Bahij_TheSansArabic-SemiBold",
        "Bahij_TheSansArabic-Bold",
        "Bahij_TheSansArabic-ExtraBold",
        "Bahij_TheSansArabic-Black",
        // خطوط النظام الاحتياطية
        "Helvetica",
        "Helvetica-Bold",
        "Times-Roman", 
        "Times-Bold",
        "Courier",
        "Courier-Bold",
        "Arial-BoldMT",
        "ArialMT",
        "Georgia",
        "Georgia-Bold"
    ]
    
    // خيارات أحجام الخط المتاحة
    let fontSizes: [CGFloat] = [8, 9, 10, 11, 12, 13, 14, 15, 16, 18, 20, 22, 24]
    
    // خيارات الألوان الشائعة المتاحة
    let commonColors: [(name: String, color: UIColor)] = [
        ("أزرق سيرا", UIColor(red: 0x00/255.0, green: 0x75/255.0, blue: 0xbe/255.0, alpha: 1.0)), // اللون الجديد #0075be
        ("أسود", .black),
        ("أزرق", .blue), 
        ("أحمر", .red),
        ("أخضر", .green),
        ("بني", .brown),
        ("بنفسجي", .purple),
        ("رمادي", .gray),
        ("برتقالي", .orange)
    ]
    
    // القسم الأول: محضر بلاغ انقطاع الخدمة الكهربائية عن
    @Published var selectedDay: String = ""
    @Published var selectedHour: Int = 12
    @Published var selectedMinute: Int = 0
    @Published var selectedPeriod: String = "صباحاً" // صباحاً أو مساءً
    @Published var selectedHijriDay: Int = 1
    @Published var location: String = ""
    
    // خيارات أيام الأسبوع
    let daysOfWeek = ["السبت", "الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة"]
    
    // خيارات الساعات (1-12)
    let hours = Array(1...12)
    
    // خيارات الدقائق (0-59)
    let minutes = Array(0...59)
    
    // خيارات الفترة
    let periods = ["صباحاً", "مساءً"]
    
    // أيام شهر ذو الحجة (1-30)
    let hijriDaysInMonth = Array(1...30)
    
    // للتوافق مع النظام القديم
    var day: String { selectedDay }
    var time: String { 
        let hourString = String(format: "%02d", selectedHour)
        let minuteString = String(format: "%02d", selectedMinute)
        return "\(hourString):\(minuteString) \(selectedPeriod)"
    }
    var date: String { "ذو الحجة \(selectedHijriDay), 1446 هـ" }
    
    // القسم الثاني: بيانات الموقع/المواقع المتأثرة
    @Published var subscriptionNumber: String = ""
    @Published var meterCapacityValue: Double = 0.0
    @Published var currentLoadValue: Double = 0.0
    
    // للتوافق مع النظام القديم
    var meterCapacity: String { 
        meterCapacityValue == 0 ? "" : String(format: "%.1f", meterCapacityValue) 
    }
    var currentLoad: String { 
        currentLoadValue == 0 ? "" : String(format: "%.1f", currentLoadValue) 
    }
    
    // القسم الثالث: مصدر البلاغ (خيارات متعددة)
    @Published var reportFromEnergySystemCenter = false
    @Published var reportFromLicensee = false
    @Published var detectedInControlCenter = false
    @Published var outageFieldVisit = false
    @Published var reportFromKadana = false
    @Published var reportFromOperatingCompany = false
    @Published var reportFromOther = false
    
    // القسم الرابع: تفاصيل إضافية للتحقق والانقطاع والإعادة
    @Published var additionalVerificationDetails: String = ""
    
    // القسم الخامس: التوصيات (حقل نص واحد فقط)
    @Published var recommendations: String = ""
    
    // القسم السادس: التواقيع (حتى 5 صفوف)
    @Published var signatures: [Signature] = []
    
    // الصور المرفقة
    @Published var selectedImages: [UIImage] = []
    
    func addImage(_ image: UIImage) {
        selectedImages.append(image)
    }
    
    func removeImage(at index: Int) {
        if index < selectedImages.count {
            selectedImages.remove(at: index)
        }
    }
    
    func addSignature() {
        if signatures.count < 5 {
            signatures.append(Signature())
        }
    }
    
    func removeSignature(at index: Int) {
        if index < signatures.count {
            signatures.remove(at: index)
        }
    }
    
    // دالة مساعدة لتخصيص إعدادات الخط - يمكن استدعاؤها في بداية التطبيق
    func customizeFontSettings(fontFamily: String? = nil, fontSize: CGFloat? = nil, textColor: UIColor? = nil) {
        if let fontFamily = fontFamily {
            selectedFontFamily = fontFamily
        }
        if let fontSize = fontSize {
            selectedFontSize = fontSize  
        }
        if let textColor = textColor {
            selectedTextColor = textColor
        }
    }
    
    func clearForm() {
        // إعادة تعيين إعدادات الخط
        selectedFontFamily = "MyriadArabic-Regular"
        selectedFontSize = 16.0
        selectedTextColor = UIColor(red: 0x00/255.0, green: 0x75/255.0, blue: 0xbe/255.0, alpha: 1.0)
        
        // إعادة تعيين اختيار القالب
        selectedTemplate = .withoutLogos
        isTemplateSelected = false
        
        selectedDay = ""
        selectedHour = 12
        selectedMinute = 0
        selectedPeriod = "صباحاً"
        selectedHijriDay = 1
        location = ""
        subscriptionNumber = ""
        meterCapacityValue = 0.0
        currentLoadValue = 0.0
        reportFromEnergySystemCenter = false
        reportFromLicensee = false
        detectedInControlCenter = false
        outageFieldVisit = false
        reportFromKadana = false
        reportFromOperatingCompany = false
        reportFromOther = false
        additionalVerificationDetails = ""
        recommendations = ""
        signatures.removeAll()
        selectedImages.removeAll()
    }
}

struct Signature: Identifiable {
    let id = UUID()
    var organization: String = ""
    var representative: String = ""
} 