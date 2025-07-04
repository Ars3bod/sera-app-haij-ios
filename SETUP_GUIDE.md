# دليل الإعداد السريع - تطبيق سيرا

## خطوات الإعداد السريع

### 1. متطلبات النظام

- macOS مع Xcode 15.0 أو أحدث
- iOS 17.0 أو أحدث للتشغيل على الجهاز
- iPad أو iPad Simulator

### 2. فتح المشروع

```bash
cd sera-app-haij-ios
open SeraApp.xcodeproj
```

### 3. إعداد Target في Xcode

1. افتح المشروع في Xcode
2. اختر `SeraApp` target
3. تأكد من أن `template_with_placeholders.pdf` مضاف إلى Bundle Resources
4. تأكد من إعداد Deployment Target على iOS 17.0

### 4. تشغيل التطبيق

1. اختر iPad simulator أو جهاز iPad متصل
2. اضغط `Cmd + R` أو زر Run في Xcode
3. سيتم بناء التطبيق وتشغيله تلقائياً

## إضافة قالب PDF مخصص

### الطريقة الأولى: استخدام القالب المُولد تلقائياً

القالب موجود بالفعل في `SeraApp/template_with_placeholders.pdf`

### الطريقة الثانية: إنشاء قالب مخصص

1. استخدم Adobe Acrobat أو PDFEscape
2. أنشئ حقول النموذج بالأسماء:
   - `name` للاسم
   - `email` للبريد الإلكتروني
   - `phone` للهاتف
   - `address` للعنوان
   - `notes` للملاحظات
3. احفظ الملف باسم `template_with_placeholders.pdf`
4. استبدل الملف في مجلد `SeraApp`

## استكشاف المشاكل

### مشكلة: لا يمكن بناء المشروع

**الحل:**

- تأكد من استخدام Xcode 15.0 أو أحدث
- تنظيف المشروع: `Product → Clean Build Folder`
- إعادة بناء المشروع

### مشكلة: قالب PDF غير موجود

**الحل:**

```bash
# تشغيل سكريبت إنشاء القالب
python3 create_pdf_template.py
```

### مشكلة: التطبيق يتعطل عند إنشاء PDF

**الحل:**

- تحقق من وجود صلاحيات الكاميرا ومعرض الصور
- تأكد من أن الصور ليست كبيرة جداً

## اختبار التطبيق

### التدفق الأساسي:

1. فتح التطبيق
2. ملء الخطوة 1: الاسم والبريد الإلكتروني
3. ملء الخطوة 2: الهاتف والعنوان
4. إضافة صور في الخطوة 3 (اختياري)
5. مراجعة البيانات في الخطوة 4
6. إنشاء PDF والمشاركة

### نصائح للاختبار:

- جرب مع صور مختلفة الأحجام
- اختبر التنقل بين الخطوات
- تأكد من عمل التحقق من البيانات
- اختبر مشاركة PDF

## التخصيص السريع

### تغيير ألوان التطبيق:

في `Assets.xcassets/AccentColor.colorset` أضف اللون المطلوب

### تعديل عدد الصور المسموحة:

في `ImagePickerView.swift` غيّر السطر:

```swift
.disabled(formData.selectedImages.count >= 4) // غيّر 4 للرقم المطلوب
```

### تخصيص مواضع الصور في PDF:

في `FormDataModel.swift` عدّل مصفوفة `imagePlacements`

---

**جاهز للتشغيل!** 🚀

لأي مساعدة إضافية، راجع ملف `README.md` للتفاصيل الكاملة.
