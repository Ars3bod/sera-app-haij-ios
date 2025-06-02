import Foundation
import UIKit

class FormFieldsModel: ObservableObject {
    // إعدادات تخصيص الخط واللون لـ PDF
    @Published var selectedFontFamily: String = "Helvetica"
    @Published var selectedFontSize: CGFloat = 12.0
    @Published var selectedTextColor: UIColor = .black
    
    // خيارات عائلات الخطوط المتاحة
    let availableFonts = [
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
    
    // خيارات أحجام الخط
    let fontSizes: [CGFloat] = [8, 9, 10, 11, 12, 13, 14, 15, 16, 18, 20, 22, 24]
    
    // خيارات الألوان الشائعة
    let commonColors: [(name: String, color: UIColor)] = [
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
    
    // القسم الرابع: مراحل إعادة الخدمة الكهربائية (حتى 3 صفوف)
    @Published var restorationPhases: [RestorationPhase] = []
    
    // القسم الخامس: تفاصيل إضافية للتحقق والانقطاع والإعادة
    @Published var additionalVerificationDetails: String = ""
    
    // القسم السادس: التوصيات (حتى 3 صفوف)
    @Published var recommendations: [Recommendation] = []
    
    // القسم السابع: التواقيع (حتى 5 صفوف)
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
    
    func addRestorationPhase() {
        if restorationPhases.count < 3 {
            restorationPhases.append(RestorationPhase())
        }
    }
    
    func removeRestorationPhase(at index: Int) {
        if index < restorationPhases.count {
            restorationPhases.remove(at: index)
        }
    }
    
    func addRecommendation() {
        if recommendations.count < 3 {
            recommendations.append(Recommendation())
        }
    }
    
    func removeRecommendation(at index: Int) {
        if index < recommendations.count {
            recommendations.remove(at: index)
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
    
    func clearForm() {
        // إعادة تعيين إعدادات الخط
        selectedFontFamily = "Helvetica"
        selectedFontSize = 12.0
        selectedTextColor = .black
        
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
        restorationPhases.removeAll()
        additionalVerificationDetails = ""
        recommendations.removeAll()
        signatures.removeAll()
        selectedImages.removeAll()
    }
}

struct RestorationPhase: Identifiable {
    let id = UUID()
    var phaseNumber: String = ""
    var outageDurationValue: Double = 0.0
    var affectedCountValue: Int = 0
    var restorationMethod: String = ""
    
    // للتوافق مع النظام القديم
    var outageeDuration: String { 
        outageDurationValue == 0 ? "" : String(format: "%.1f", outageDurationValue) 
    }
    var affectedCount: String { 
        affectedCountValue == 0 ? "" : String(affectedCountValue) 
    }
}

struct Recommendation: Identifiable {
    let id = UUID()
    var recommendationText: String = ""
    var responsibleParty: String = ""
    var targetHijriYear: Int = 1446
    var targetHijriMonth: Int = 1
    var targetHijriDay: Int = 1
    
    // أشهر السنة الهجرية
    static let hijriMonths = [
        "محرم", "صفر", "ربيع الأول", "ربيع الثاني", "جمادى الأولى", "جمادى الثانية",
        "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"
    ]
    
    // للتوافق مع النظام القديم
    var targetDate: String { 
        if targetHijriYear == 1446 && targetHijriMonth == 1 && targetHijriDay == 1 {
            return ""
        }
        let monthName = Recommendation.hijriMonths[targetHijriMonth - 1]
        return "\(monthName) \(targetHijriDay), \(targetHijriYear) هـ"
    }
}

struct Signature: Identifiable {
    let id = UUID()
    var organization: String = ""
    var representative: String = ""
} 