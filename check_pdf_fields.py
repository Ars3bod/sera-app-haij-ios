import PyPDF2
import sys
import os

def check_pdf_fields(pdf_path):
    """
    فحص حقول PDF وعرض تفاصيلها
    """
    try:
        with open(pdf_path, 'rb') as file:
            pdf_reader = PyPDF2.PdfReader(file)
            
            print(f"📄 ملف PDF: {pdf_path}")
            print(f"📊 عدد الصفحات: {len(pdf_reader.pages)}")
            print("-" * 50)
            
            # فحص كل صفحة
            for page_num, page in enumerate(pdf_reader.pages):
                print(f"\n📖 الصفحة {page_num + 1}:")
                
                # الحصول على أبعاد الصفحة
                if '/MediaBox' in page:
                    media_box = page['/MediaBox']
                    print(f"   أبعاد الصفحة: {media_box}")
                
                # فحص الحقول في الصفحة
                if '/Annots' in page:
                    annotations = page['/Annots']
                    print(f"   عدد الحقول/التعليقات: {len(annotations)}")
                    
                    for i, annot_ref in enumerate(annotations):
                        try:
                            annot = annot_ref.get_object()
                            field_name = ""
                            field_type = ""
                            field_rect = []
                            
                            # اسم الحقل
                            if '/T' in annot:
                                field_name = annot['/T']
                            
                            # نوع الحقل
                            if '/Subtype' in annot:
                                field_type = annot['/Subtype']
                            
                            # موضع الحقل
                            if '/Rect' in annot:
                                field_rect = annot['/Rect']
                            
                            print(f"      {i+1}. اسم الحقل: '{field_name}'")
                            print(f"         نوع الحقل: {field_type}")
                            print(f"         الموضع: {field_rect}")
                            
                            # التحقق من حقول الصور المطلوبة
                            image_fields = ['Image_1', 'Image_2', 'Image_3', 'Image_4']
                            if field_name in image_fields:
                                print(f"         ✅ هذا حقل صورة مطلوب!")
                            
                            print()
                            
                        except Exception as e:
                            print(f"         خطأ في قراءة الحقل {i+1}: {e}")
                else:
                    print("   ❌ لا توجد حقول في هذه الصفحة")
            
            # فحص الحقول على مستوى المستند
            if hasattr(pdf_reader, 'get_form_text_fields'):
                form_fields = pdf_reader.get_form_text_fields()
                if form_fields:
                    print(f"\n📝 حقول النماذج في المستند:")
                    for field_name, field_value in form_fields.items():
                        print(f"   {field_name}: {field_value}")
            
            # التحقق من وجود حقول الصور المطلوبة
            print(f"\n🔍 البحث عن حقول الصور المطلوبة:")
            required_fields = ['Image_1', 'Image_2', 'Image_3', 'Image_4']
            found_fields = []
            
            for page_num, page in enumerate(pdf_reader.pages):
                if '/Annots' in page:
                    for annot_ref in page['/Annots']:
                        try:
                            annot = annot_ref.get_object()
                            if '/T' in annot:
                                field_name = annot['/T']
                                if field_name in required_fields:
                                    found_fields.append(field_name)
                                    print(f"   ✅ وُجد: {field_name} في الصفحة {page_num + 1}")
                        except:
                            continue
            
            missing_fields = set(required_fields) - set(found_fields)
            if missing_fields:
                print(f"   ❌ مفقود: {list(missing_fields)}")
            else:
                print("   🎉 جميع حقول الصور موجودة!")
                
    except Exception as e:
        print(f"❌ خطأ في قراءة ملف PDF: {e}")

if __name__ == "__main__":
    pdf_path = "SeraApp/template_with_placeholders.pdf"
    
    if os.path.exists(pdf_path):
        check_pdf_fields(pdf_path)
    else:
        print(f"❌ لم يتم العثور على الملف: {pdf_path}") 