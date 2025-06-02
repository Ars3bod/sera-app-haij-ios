#!/usr/bin/env python3
"""
سكريبت لإنشاء قالب PDF نموذجي لتطبيق سيرا
يتضمن حقول النموذج ومساحات للصور
"""

from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.pdfbase import pdfform
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase import pdfutils
import os

def create_pdf_template():
    """إنشاء قالب PDF مع حقول النموذج ومساحات الصور"""
    
    filename = "SeraApp/template_with_placeholders.pdf"
    
    # إنشاء canvas للـ PDF
    c = canvas.Canvas(filename, pagesize=A4)
    width, height = A4
    
    # إعداد الخط (للنص العربي - افتراضي)
    c.setFont("Helvetica-Bold", 16)
    
    # العنوان الرئيسي
    title = "Sera App - Form Template"
    c.drawCentredString(width/2, height - 50, title)
    
    # معلومات النموذج
    c.setFont("Helvetica", 12)
    y_position = height - 100
    
    # حقل الاسم
    c.drawString(50, y_position, "Name / الاسم:")
    c.acroForm.textfield(
        name='name',
        tooltip='Enter your full name',
        x=150, y=y_position-5,
        borderStyle='inset',
        width=300,
        height=20,
        textColor=colors.black,
        fillColor=colors.white,
        borderColor=colors.black,
        forceBorder=True
    )
    
    y_position -= 40
    
    # حقل البريد الإلكتروني
    c.drawString(50, y_position, "Email / البريد الإلكتروني:")
    c.acroForm.textfield(
        name='email',
        tooltip='Enter your email address',
        x=150, y=y_position-5,
        borderStyle='inset',
        width=300,
        height=20,
        textColor=colors.black,
        fillColor=colors.white,
        borderColor=colors.black,
        forceBorder=True
    )
    
    y_position -= 40
    
    # حقل الهاتف
    c.drawString(50, y_position, "Phone / الهاتف:")
    c.acroForm.textfield(
        name='phone',
        tooltip='Enter your phone number',
        x=150, y=y_position-5,
        borderStyle='inset',
        width=300,
        height=20,
        textColor=colors.black,
        fillColor=colors.white,
        borderColor=colors.black,
        forceBorder=True
    )
    
    y_position -= 40
    
    # حقل العنوان
    c.drawString(50, y_position, "Address / العنوان:")
    c.acroForm.textfield(
        name='address',
        tooltip='Enter your address',
        x=150, y=y_position-5,
        borderStyle='inset',
        width=300,
        height=20,
        textColor=colors.black,
        fillColor=colors.white,
        borderColor=colors.black,
        forceBorder=True
    )
    
    y_position -= 60
    
    # حقل الملاحظات
    c.drawString(50, y_position, "Notes / ملاحظات:")
    c.acroForm.textfield(
        name='notes',
        tooltip='Additional notes',
        x=150, y=y_position-45,
        borderStyle='inset',
        width=300,
        height=60,
        textColor=colors.black,
        fillColor=colors.white,
        borderColor=colors.black,
        forceBorder=True
    )
    
    # مساحات الصور
    y_position -= 120
    
    c.setFont("Helvetica-Bold", 14)
    c.drawString(50, y_position, "Image Attachments / الصور المرفقة:")
    
    y_position -= 30
    
    # رسم مربعات للصور (هذه المواضع يجب أن تتطابق مع imagePlacements في الكود)
    image_positions = [
        (100, y_position - 150),  # الصورة الأولى
        (350, y_position - 150),  # الصورة الثانية
        (100, y_position - 320),  # الصورة الثالثة
        (350, y_position - 320)   # الصورة الرابعة
    ]
    
    c.setStrokeColor(colors.gray)
    c.setFillColor(colors.lightgrey)
    
    for i, (x, y) in enumerate(image_positions):
        # رسم مربع للصورة
        c.rect(x, y, 200, 150, fill=1, stroke=1)
        
        # إضافة نص توضيحي
        c.setFillColor(colors.black)
        c.setFont("Helvetica", 10)
        c.drawCentredString(x + 100, y + 75, f"Image {i+1}")
        c.drawCentredString(x + 100, y + 60, f"صورة {i+1}")
        c.setFillColor(colors.lightgrey)
    
    # إضافة تاريخ الإنشاء
    c.setFillColor(colors.black)
    c.setFont("Helvetica", 8)
    c.drawString(50, 30, f"Template created for Sera App")
    c.drawRightString(width - 50, 30, "Generated PDF Template")
    
    # حفظ PDF
    c.save()
    print(f"تم إنشاء قالب PDF: {filename}")

def install_requirements():
    """تثبيت المكتبات المطلوبة"""
    try:
        import reportlab
        print("مكتبة reportlab متوفرة")
    except ImportError:
        print("تثبيت مكتبة reportlab...")
        os.system("pip install reportlab")

if __name__ == "__main__":
    print("إنشاء قالب PDF لتطبيق سيرا...")
    
    # التأكد من توفر المكتبة المطلوبة
    install_requirements()
    
    # إنشاء مجلد SeraApp إذا لم يكن موجوداً
    os.makedirs("SeraApp", exist_ok=True)
    
    # إنشاء قالب PDF
    create_pdf_template()
    
    print("تم إنشاء قالب PDF بنجاح!")
    print("يمكنك الآن إضافة الملف إلى مشروع Xcode.") 