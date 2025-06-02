import SwiftUI

struct FillableFormView: View {
    @StateObject private var formData = FormFieldsModel()
    @ObservedObject var pdfManager: PDFManager
    @State private var showingImagePicker = false
    @State private var showingSourceSelection = false
    @State private var showingSuccess = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // رأس النموذج
                VStack(spacing: 15) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("محضر بلاغ انقطاع الخدمة الكهربائية")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("يرجى ملء جميع الحقول المطلوبة بدقة")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 10)
                
                // قسم اختيار القالب
                if !formData.isTemplateSelected {
                    TemplateSelectionView(formData: formData)
                } else {
                    // قسم عرض القالب المختار
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("القالب المختار")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: {
                                formData.isTemplateSelected = false
                            }) {
                                Text("تغيير")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        HStack {
                            Text(formData.selectedTemplate.displayName)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                    
                    // باقي حقول النموذج
                    VStack(spacing: 25) {
                        // القسم الأول: محضر بلاغ انقطاع الخدمة الكهربائية عن
                        FormSectionView(title: "محضر بلاغ انقطاع الخدمة الكهربائية عن", icon: "doc.text.fill", color: .orange) {
                            VStack(spacing: 15) {
                                // اختيار اليوم
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("اليوم")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Picker("اختر اليوم", selection: $formData.selectedDay) {
                                        Text("اختر اليوم").tag("")
                                        ForEach(formData.daysOfWeek, id: \.self) { day in
                                            Text(day).tag(day)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                
                                // اختيار الوقت (ساعة:دقيقة صباحاً/مساءً)
                                TimePickerView(
                                    selectedHour: $formData.selectedHour,
                                    selectedMinute: $formData.selectedMinute,
                                    selectedPeriod: $formData.selectedPeriod,
                                    hours: formData.hours,
                                    minutes: formData.minutes,
                                    periods: formData.periods
                                )
                                
                                // اختيار التاريخ الهجري
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("التاريخ (ذو الحجة 1446 هـ)")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Picker("اختر اليوم", selection: $formData.selectedHijriDay) {
                                        ForEach(formData.hijriDaysInMonth, id: \.self) { day in
                                            Text("ذو الحجة \(day), 1446 هـ").tag(day)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                
                                FormFieldView(title: "الموقع", text: $formData.location, placeholder: "أدخل الموقع")
                            }
                        }
                        
                        // القسم الثاني: بيانات الموقع/المواقع المتأثرة
                        FormSectionView(title: "بيانات الموقع/المواقع المتأثرة", icon: "location.fill", color: .blue) {
                            VStack(spacing: 15) {
                                FormFieldView(title: "رقم الاشتراك/الاشتراكات", text: $formData.subscriptionNumber, placeholder: "أدخل رقم الاشتراك")
                                
                                // سعة العداد (رقمي)
                                NumericFieldView(title: "سعة العداد (أمبير)", value: $formData.meterCapacityValue, placeholder: "أدخل سعة العداد", unit: "أمبير")
                                
                                // الحمل الحالي (رقمي)
                                NumericFieldView(title: "الحمل الحالي (أمبير)", value: $formData.currentLoadValue, placeholder: "أدخل الحمل الحالي", unit: "أمبير")
                            }
                        }
                        
                        // القسم الثالث: مصدر البلاغ
                        FormSectionView(title: "مصدر البلاغ", icon: "phone.fill", color: .green) {
                            VStack(spacing: 15) {
                                CheckboxView(title: "بلاغ وارد لمركز منظومة الطاقة", isChecked: $formData.reportFromEnergySystemCenter)
                                CheckboxView(title: "بلاغ من المرخص له", isChecked: $formData.reportFromLicensee)
                                CheckboxView(title: "رصد في مركز التحكم الخاص بالمرخص له في مشعر منى", isChecked: $formData.detectedInControlCenter)
                                CheckboxView(title: "انقطاع خلال زيارة ميدانية", isChecked: $formData.outageFieldVisit)
                                CheckboxView(title: "بلاغ من شركة كدانة", isChecked: $formData.reportFromKadana)
                                CheckboxView(title: "بلاغ من الشركة المشغلة لمخيمات الحجاج", isChecked: $formData.reportFromOperatingCompany)
                                CheckboxView(title: "أخرى", isChecked: $formData.reportFromOther)
                            }
                        }
                        
                        // القسم الرابع: تفاصيل إضافية للتحقق والانقطاع والإعادة
                        FormSectionView(title: "تفاصيل إضافية للتحقق والانقطاع والإعادة", icon: "doc.text.below.ecg", color: .indigo) {
                            VStack(spacing: 15) {
                                MultilineTextFieldView(title: "التفاصيل الإضافية", text: $formData.additionalVerificationDetails, placeholder: "أدخل أي تفاصيل إضافية")
                            }
                        }
                        
                        // القسم الخامس: التوصيات
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("5. التوصيات")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("التوصيات:")
                                    .font(.headline)
                                
                                TextEditor(text: $formData.recommendations)
                                    .frame(minHeight: 100)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        
                        // القسم السادس: التواقيع
                        FormSectionView(title: "التواقيع", icon: "signature", color: .red) {
                            VStack(spacing: 15) {
                                ForEach(formData.signatures.indices, id: \.self) { index in
                                    SignatureView(
                                        signature: $formData.signatures[index],
                                        index: index + 1,
                                        onDelete: {
                                            formData.removeSignature(at: index)
                                        },
                                        templateType: formData.selectedTemplate
                                    )
                                }
                                
                                if formData.signatures.count < 5 {
                                    Button(action: {
                                        formData.addSignature()
                                    }) {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                            Text("إضافة توقيع")
                                        }
                                        .foregroundColor(.red)
                                        .padding()
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                        // القسم السابع: المرفقات (الصور)
                        FormSectionView(title: "المرفقات (الصور)", icon: "photo.fill", color: .mint) {
                            VStack(spacing: 15) {
                                Text("يمكن إضافة حتى 8 صور كمرفقات")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                if formData.selectedImages.isEmpty {
                                    Button(action: {
                                        showingSourceSelection = true
                                    }) {
                                        VStack(spacing: 12) {
                                            Image(systemName: "photo.badge.plus")
                                                .font(.system(size: 40))
                                                .foregroundColor(.mint)
                                            
                                            Text("أضف الصور")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 100)
                                        .background(Color.mint.opacity(0.1))
                                        .cornerRadius(15)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.mint, style: StrokeStyle(lineWidth: 2, dash: [8]))
                                        )
                                    }
                                } else {
                                    VStack(spacing: 15) {
                                        HStack {
                                            Text("الصور المرفقة (\(formData.selectedImages.count)/8)")
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                        }
                                        
                                        LazyVGrid(columns: [
                                            GridItem(.flexible()),
                                            GridItem(.flexible())
                                        ], spacing: 15) {
                                            ForEach(formData.selectedImages.indices, id: \.self) { index in
                                                ImageThumbnailView(
                                                    image: formData.selectedImages[index],
                                                    onDelete: {
                                                        formData.removeImage(at: index)
                                                    }
                                                )
                                            }
                                            
                                            if formData.selectedImages.count < 8 {
                                                AddImageButton(action: {
                                                    showingSourceSelection = true
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // زر إنشاء PDF
                        VStack(spacing: 15) {
                            Button(action: {
                                pdfManager.generateFilledPDF(with: formData) { url in
                                    if url != nil {
                                        showingSuccess = true
                                    }
                                }
                            }) {
                                HStack {
                                    if pdfManager.isProcessing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                        Text("جاري الإنشاء...")
                                            .fontWeight(.semibold)
                                    } else {
                                        Image(systemName: "doc.fill")
                                        Text("إنشاء محضر PDF")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(pdfManager.isProcessing)
                            
                            if let errorMessage = pdfManager.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .actionSheet(isPresented: $showingSourceSelection) {
            ActionSheet(
                title: Text("اختر مصدر الصورة"),
                buttons: [
                    .default(Text("الكاميرا")) {
                        sourceType = .camera
                        showingImagePicker = true
                    },
                    .default(Text("معرض الصور")) {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    },
                    .cancel(Text("إلغاء"))
                ]
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
        }
        .onChange(of: selectedImage) { _, image in
            if let image = image {
                formData.addImage(image)
                selectedImage = nil
            }
        }
        .sheet(isPresented: $showingSuccess) {
            if let pdfURL = pdfManager.generatedPDFURL {
                PDFSuccessView(pdfURL: pdfURL, pdfManager: pdfManager)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

struct CheckboxView: View {
    let title: String
    @Binding var isChecked: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                isChecked.toggle()
            }) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundColor(isChecked ? .green : .gray)
            }
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

struct MultilineTextFieldView: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            TextEditor(text: $text)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .environment(\.layoutDirection, .rightToLeft)
        }
    }
}

// مكون لإدخال الأرقام
struct NumericFieldView: View {
    let title: String
    @Binding var value: Double
    let placeholder: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack {
                TextField(placeholder, value: $value, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.trailing)
                
                Text(unit)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
        }
    }
}

// مكون لإدخال الأرقام الصحيحة
struct IntegerFieldView: View {
    let title: String
    @Binding var value: Int
    let placeholder: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack {
                TextField(placeholder, value: $value, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.trailing)
                
                Text(unit)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
        }
    }
}

// مكون لاختيار التاريخ الهجري
struct HijriDatePickerView: View {
    let title: String
    @Binding var year: Int
    @Binding var month: Int
    @Binding var day: Int
    
    let startYear: Int = 1446
    let endYear: Int = 1450
    
    // أسماء الأشهر الهجرية
    private let hijriMonths = [
        "محرم", "صفر", "ربيع الأول", "ربيع الثاني", "جمادى الأول", "جمادى الثاني",
        "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack(spacing: 10) {
                // اختيار السنة
                Picker("السنة", selection: $year) {
                    ForEach(startYear...endYear, id: \.self) { year in
                        Text("\(year) هـ").tag(year)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // اختيار الشهر
                Picker("الشهر", selection: $month) {
                    ForEach(1...12, id: \.self) { month in
                        Text(hijriMonths[month - 1]).tag(month)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // اختيار اليوم
                Picker("اليوم", selection: $day) {
                    ForEach(1...30, id: \.self) { day in
                        Text("\(day)").tag(day)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

struct SignatureView: View {
    @Binding var signature: Signature
    let index: Int
    let onDelete: () -> Void
    let templateType: TemplateType
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("التوقيع \(index)")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
            
            VStack(spacing: 10) {
                // حقل الجهة - مقفل إذا كان القالب مع شعارات
                if templateType == .withLogos {
                    LockedFormFieldView(title: "الجهة", lockedText: "الجهة محددة بالقالب")
                } else {
                    FormFieldView(title: "الجهة", text: $signature.organization, placeholder: "أدخل اسم الجهة")
                }
                
                FormFieldView(title: "ممثل الجهة", text: $signature.representative, placeholder: "أدخل اسم ممثل الجهة")
            }
        }
        .padding()
        .background(Color.brown.opacity(0.05))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.brown.opacity(0.3), lineWidth: 1)
        )
    }
}

struct FormSectionView<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct FormFieldView: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .environment(\.layoutDirection, .rightToLeft)
        }
    }
}

// حقل مقفل (غير قابل للتحرير)
struct LockedFormFieldView: View {
    let title: String
    let lockedText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack {
                Text(lockedText)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                
                Image(systemName: "lock.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
        }
    }
}

struct TimePickerView: View {
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int
    @Binding var selectedPeriod: String
    let hours: [Int]
    let minutes: [Int]
    let periods: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("الوقت")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // صف التسميات
                HStack {
                    Spacer()
                    
                    Text("الساعة")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 80)
                    
                    Spacer()
                        .frame(width: 20)
                    
                    Text("الدقيقة")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 80)
                    
                    Text("الفترة")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 100)
                    
                    Spacer()
                }
                
                // صف المنتقيات
                HStack(spacing: 10) {
                    Spacer()
                    
                    // اختيار الساعة (1-12)
                    Picker("الساعة", selection: $selectedHour) {
                        ForEach(hours, id: \.self) { hour in
                            Text("\(hour) س").tag(hour)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 80)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    Text(":")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    // اختيار الدقيقة (0-59)
                    Picker("الدقيقة", selection: $selectedMinute) {
                        ForEach(minutes, id: \.self) { minute in
                            Text("\(String(format: "%02d", minute)) د").tag(minute)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 80)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    // اختيار الفترة (صباحاً/مساءً)
                    Picker("الفترة", selection: $selectedPeriod) {
                        ForEach(periods, id: \.self) { period in
                            Text(period).tag(period)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 100)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    Spacer()
                }
                
                // عرض الوقت المحدد
                HStack {
                    Spacer()
                    
                    Text("الوقت المحدد:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(selectedHour):\(String(format: "%02d", selectedMinute)) \(selectedPeriod)")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.top, 5)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

// عرض اختيار القالب
struct TemplateSelectionView: View {
    @ObservedObject var formData: FormFieldsModel
    @State private var selectedType: TemplateType = .withoutLogos
    
    var body: some View {
        VStack(spacing: 20) {
            // رأس القسم
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("اختيار القالب")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Text("يرجى اختيار نوع القالب المطلوب")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // خيارات القوالب
            VStack(spacing: 15) {
                ForEach(TemplateType.allCases, id: \.self) { templateType in
                    TemplateOptionView(
                        templateType: templateType,
                        isSelected: selectedType == templateType,
                        onTap: {
                            selectedType = templateType
                        }
                    )
                }
            }
            
            // زر التأكيد
            Button(action: {
                formData.selectedTemplate = selectedType
                formData.isTemplateSelected = true
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("تأكيد الاختيار")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

// عرض خيار قالب واحد
struct TemplateOptionView: View {
    let templateType: TemplateType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .font(.title2)
                    
                    Text(templateType.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if templateType == .withLogos {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
                
                Text(templateType.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                if templateType == .withLogos {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("ملاحظة: حقل الجهة سيكون مقفلاً في التواقيع")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FillableFormView_Previews: PreviewProvider {
    static var previews: some View {
        FillableFormView(pdfManager: PDFManager())
    }
} 