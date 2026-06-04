from pathlib import Path
from textwrap import wrap

from PIL import Image, ImageDraw, ImageFont


OUT_DIR = Path("/Users/adeel.arshad/Documents/Codex/2026-06-02/you-are-health-fitness-workout-and/outputs/PakFit/screens")
OUT_DIR.mkdir(parents=True, exist_ok=True)

W, H = 1080, 1920
BG = "#F6F8F4"
SURFACE = "#FFFFFF"
TEXT = "#20231F"
MUTED = "#6B7068"
PRIMARY = "#17694D"
SECONDARY = "#9A5B24"
TERTIARY = "#24698C"
WARN = "#B44A2A"
DANGER = "#9E1B1B"
LINE = "#E4E9DE"
PALE_GREEN = "#EAF3EC"
PALE_BLUE = "#E8F1F5"
PALE_ORANGE = "#FFF6E8"

FONT_REG = "/System/Library/Fonts/Supplemental/Arial Unicode.ttf"
FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


def font(size, bold=False):
    return ImageFont.truetype(FONT_BOLD if bold else FONT_REG, size)


def new_canvas():
    return Image.new("RGB", (W, H), BG)


def round_rect(draw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def text(draw, xy, value, size=34, fill=TEXT, bold=False, max_width=920, line_gap=10, rtl=False):
    x, y = xy
    f = font(size, bold)
    words = value.split(" ")
    lines = []
    current = ""
    for word in words:
        candidate = word if not current else current + " " + word
        if draw.textlength(candidate, font=f) <= max_width:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    if not lines:
        lines = [value]
    for line in lines:
        kwargs = {"font": f, "fill": fill}
        if rtl:
            draw.text((x + max_width, y), line, anchor="ra", **kwargs)
        else:
            draw.text((x, y), line, **kwargs)
        y += size + line_gap
    return y


def header(draw, title, subtitle):
    draw.rectangle((0, 0, W, 170), fill=BG)
    text(draw, (64, 50), title, size=58, bold=True, max_width=680)
    text(draw, (64, 118), subtitle, size=28, fill=MUTED, max_width=880, line_gap=4)


def card(draw, y, title, height, fill=SURFACE):
    x = 44
    round_rect(draw, (x, y, W - x, y + height), 20, fill, outline="#E9EEE3")
    text(draw, (x + 28, y + 24), title, size=36, bold=True, max_width=880)
    return x + 28, y + 84, y + height


def chip(draw, x, y, label, selected=False, fill=None):
    f = font(25, selected)
    pad_x = 22
    w = int(draw.textlength(label, font=f)) + pad_x * 2
    h = 54
    bg = fill or (PALE_GREEN if selected else "#F7F8F5")
    outline = PRIMARY if selected else "#DCE4D6"
    round_rect(draw, (x, y, x + w, y + h), 27, bg, outline=outline)
    draw.text((x + pad_x, y + 14), label, font=f, fill=PRIMARY if selected else TEXT)
    return x + w + 12


def chip_row(draw, x, y, labels, selected=None, max_x=1010):
    selected = set(selected or [])
    start = x
    for label in labels:
        f = font(25, label in selected)
        w = int(draw.textlength(label, font=f)) + 44
        if x + w > max_x:
            x = start
            y += 68
        x = chip(draw, x, y, label, label in selected)
    return y + 64


def slider(draw, x, y, label, value_text, progress, color=PRIMARY):
    text(draw, (x, y), label, size=27, max_width=450)
    right = x + 870
    f = font(27, True)
    draw.text((right, y), value_text, font=f, fill=TEXT, anchor="ra")
    bar_y = y + 48
    round_rect(draw, (x, bar_y, right, bar_y + 14), 7, LINE)
    round_rect(draw, (x, bar_y, x + int((right - x) * max(0, min(1, progress))), bar_y + 14), 7, color)
    return y + 88


def metric(draw, x, y, label, value, color=PRIMARY):
    round_rect(draw, (x, y, x + 290, y + 126), 18, "#F8FAF6", outline="#E8EEE2")
    text(draw, (x + 20, y + 18), value, size=36, bold=True, fill=color, max_width=245)
    text(draw, (x + 20, y + 70), label, size=23, fill=MUTED, max_width=245)


def bullets(draw, x, y, items, size=25, max_width=850):
    for item in items:
        y = text(draw, (x, y), f"- {item}", size=size, fill=TEXT, max_width=max_width, line_gap=5) + 4
    return y


def progress_line(draw, x, y, title, value, progress, color):
    text(draw, (x, y), title, size=28, bold=True, max_width=580)
    draw.text((x + 870, y), value, font=font(28, True), fill=color, anchor="ra")
    round_rect(draw, (x, y + 48, x + 870, y + 62), 7, LINE)
    round_rect(draw, (x, y + 48, x + int(870 * progress), y + 62), 7, color)
    return y + 88


def bar_chart(draw, x, y, title, labels, values, color):
    text(draw, (x, y), title, size=30, bold=True, max_width=860)
    y += 54
    max_v = max(max(values), 1)
    for label, value in zip(labels, values):
        draw.text((x, y), label, font=font(23), fill=MUTED)
        round_rect(draw, (x + 95, y + 8, x + 760, y + 28), 10, LINE)
        round_rect(draw, (x + 95, y + 8, x + 95 + int(665 * value / max_v), y + 28), 10, color)
        draw.text((x + 850, y - 2), str(value), font=font(24, True), fill=TEXT, anchor="ra")
        y += 48
    return y + 10


def screen_home():
    img = new_canvas()
    draw = ImageDraw.Draw(img)
    header(draw, "PakFit", "Desi meals, realistic workouts, and habits built for Pakistani routines.")
    x, y, _ = card(draw, 200, "Profile", 420)
    y = chip_row(draw, x, y, ["Female", "Male"], selected=["Male"])
    y = slider(draw, x, y + 8, "Age", "30 years", 0.24)
    y = slider(draw, x, y, "Height", "170 cm", 0.47)
    slider(draw, x, y, "Weight", "75 kg", 0.32)

    x, y, _ = card(draw, 650, "Goal & Routine", 390)
    y = chip_row(draw, x, y, ["Fat loss", "Muscle gain", "General fitness"], selected=["Fat loss"])
    y = chip_row(draw, x, y + 12, ["Mostly sitting", "Walks sometimes", "Active routine"], selected=["Walks sometimes"])
    y = chip_row(draw, x, y + 12, ["Halal omnivore", "Vegetarian", "Egg friendly"], selected=["Halal omnivore"])
    chip_row(draw, x, y + 12, ["Home", "Gym"], selected=["Home"])

    x, y, _ = card(draw, 1070, "Plan Snapshot", 560)
    metric(draw, x, y, "Daily calories", "2050", PRIMARY)
    metric(draw, x + 310, y, "Protein", "135 g", SECONDARY)
    metric(draw, x + 620, y, "Water", "2.6 L", TERTIARY)
    y += 160
    y = bullets(draw, x, y, [
        "Anchor meals with chicken, fish, beef qeema, eggs, daal, or dahi.",
        "Use one palm protein, one fist rice or one roti, and half plate sabzi or salad.",
        "Walk 8 to 10 minutes after lunch or dinner to support glucose control.",
    ])
    text(draw, (x, y + 16), "Workout: Home fat-loss foundation", size=31, bold=True)
    bullets(draw, x, y + 70, [
        "4 days per week",
        "Bodyweight strength, walk intervals, mobility, and core",
        "Avoid prayer windows; choose after Fajr, after Asr, or after Isha"
    ])
    img.save(OUT_DIR / "01-home-profile-plan.png")


def screen_health():
    img = new_canvas()
    draw = ImageDraw.Draw(img)
    header(draw, "Health Markers", "BMI, lipid profile, uric acid, blood sugar, HbA1c, hemoglobin, and BP.")
    x, y, _ = card(draw, 200, "Marker Inputs", 930)
    y = chip_row(draw, x, y, ["No diabetes", "Prediabetes", "Diabetes"], selected=["Prediabetes"])
    for label, value, progress, color in [
        ("Total cholesterol", "220 mg/dL", 0.56, WARN),
        ("LDL", "140 mg/dL", 0.53, WARN),
        ("HDL", "35 mg/dL", 0.15, SECONDARY),
        ("Triglycerides", "180 mg/dL", 0.41, WARN),
        ("Uric acid", "8.4 mg/dL", 0.64, WARN),
        ("Fasting sugar", "130 mg/dL", 0.18, SECONDARY),
        ("Systolic BP", "142 mmHg", 0.41, WARN),
        ("HbA1c", "6.7%", 0.40, WARN),
        ("Hemoglobin", "11.0 g/dL", 0.30, SECONDARY),
    ]:
        y = slider(draw, x, y + 2, label, value, progress, color)

    x, y, _ = card(draw, 1160, "BMI & Reports", 580, fill="#FFFDF8")
    text(draw, (x, y), "BMI 28.4 - Obesity class 1", size=34, bold=True, max_width=880)
    y += 58
    y = text(draw, (x, y), "BMI uses South Asian screening cutoffs and is not a diagnosis. Review it with waist, labs, symptoms, and clinician advice.", size=26, fill=MUTED, max_width=870)
    y = text(draw, (x, y + 6), "یہ معلومات طبی مشورہ نہیں ہے۔ ہمیشہ اپنے ڈاکٹر سے رجوع کریں۔", size=28, bold=True, max_width=870, rtl=True)
    y += 18
    y = bullets(draw, x, y, [
        "Lipid profile review: cholesterol, LDL, HDL, or triglycerides outside screening targets.",
        "Blood pressure review: repeated high readings should be reviewed with a doctor.",
        "HbA1c review: blood sugar risk should be reviewed with a healthcare professional.",
        "Hemoglobin review: low value can relate to anemia and needs clinical context.",
    ], size=24)
    img.save(OUT_DIR / "02-health-markers-bmi-reports.png")


def screen_clinical():
    img = new_canvas()
    draw = ImageDraw.Draw(img)
    header(draw, "Clinical Intelligence", "On-device screening insights for Pakistani/South Asian users.")
    x, y, _ = card(draw, 200, "Clinical Risk Inputs", 360)
    text(draw, (x, y), "Optional context for family history, salt routine, sun exposure, iron intake, and tobacco.", size=26, fill=MUTED, max_width=870)
    y += 78
    chip_row(
        draw, x, y,
        ["Family history diabetes", "Family history high BP", "High-salt routine", "Low sun exposure", "Smoking or tobacco", "Low-iron diet"],
        selected=["Family history diabetes", "Family history high BP", "High-salt routine", "Low sun exposure"]
    )

    x, y, _ = card(draw, 590, "Risk Insight Report", 1060)
    y = text(draw, (x, y), "Screening insight only. This is not a diagnosis or treatment plan.", size=26, fill=MUTED, max_width=870)
    y = text(draw, (x, y + 4), "یہ معلومات طبی مشورہ نہیں ہے۔ ہمیشہ اپنے ڈاکٹر سے رجوع کریں۔", size=27, bold=True, max_width=870, rtl=True)
    y += 30
    for title, level, score, color, urdu, steps in [
        ("Diabetes risk screening", "High", 0.82, WARN, "ٹائپ 2 ذیابیطس کا خطر بڑھا ہوا لگتا ہے؛ یہ تشخیص نہیں ہے۔", ["Review HbA1c and fasting glucose with your doctor.", "Use protein, sabzi, measured roti/rice, and a walk after meals."]),
        ("Blood pressure risk screening", "High", 0.72, WARN, "بلڈ پریشر کے اعداد اور عادات سے خطر بڑھا ہوا لگتا ہے۔", ["Recheck BP calmly on different days.", "Reduce added salt, achar, and packaged snacks."]),
        ("Heart health risk screening", "Moderate", 0.58, SECONDARY, "کولیسٹرول، بلڈ پریشر، شوگر، عمر، وزن یا خاندانی تاریخ دل کے خطرے کو بڑھا سکتے ہیں۔", ["Book clinician review for cholesterol, BP, and glucose together."]),
        ("Vitamin D risk screening", "Moderate", 0.50, TERTIARY, "کم دھوپ یا زیادہ وزن سے وٹامن ڈی کی کمی کا خطر بڑھ سکتا ہے۔", ["Ask about vitamin D lab testing when symptoms or repeated deficiency are concerns."]),
        ("Iron and anemia risk screening", "Low", 0.22, PRIMARY, "آئرن والی غذا کم ہونا انیمیا کا خطر بڑھا سکتا ہے۔", ["Use iron-rich foods such as saag, daal, chana, lobia, eggs, fish, or beef when suitable."]),
    ]:
        text(draw, (x, y), f"{title}: {level}", size=29, bold=True, max_width=720)
        draw.text((x + 870, y), f"{int(score*10)}/10", font=font(28, True), fill=color, anchor="ra")
        round_rect(draw, (x, y + 45, x + 870, y + 59), 7, LINE)
        round_rect(draw, (x, y + 45, x + int(870 * score), y + 59), 7, color)
        y = text(draw, (x, y + 76), urdu, size=25, bold=True, max_width=870, rtl=True)
        y = bullets(draw, x, y + 2, steps, size=23)
        y += 18
    img.save(OUT_DIR / "03-clinical-intelligence.png")


def screen_mental():
    img = new_canvas()
    draw = ImageDraw.Draw(img)
    header(draw, "Mental Wellness", "PHQ-9/GAD-7 screening and Pakistan crisis support.")
    x, y, _ = card(draw, 200, "Screening Scores", 550)
    text(draw, (x, y), "Screening tools only. Use crisis flags whenever immediate safety is a concern.", size=26, fill=MUTED, max_width=870)
    y += 82
    y = slider(draw, x, y, "PHQ-9 score", "15 / 27", 15 / 27, WARN)
    y = slider(draw, x, y + 8, "GAD-7 score", "16 / 21", 16 / 21, DANGER)
    y = chip_row(draw, x, y + 12, ["Self-harm thoughts", "Panic or severe distress", "Cannot stay safe"], selected=["Self-harm thoughts", "Cannot stay safe"])
    text(draw, (x, y + 24), "PHQ-9: 15 - Moderately severe", size=30, bold=True)
    text(draw, (x, y + 74), "GAD-7: 16 - Severe", size=30, bold=True)

    x, y, _ = card(draw, 790, "Crisis Support", 850, fill="#FFF4F2")
    text(draw, (x, y), "Crisis support needed", size=36, bold=True, fill=DANGER)
    y = text(draw, (x, y + 58), "If you may hurt yourself, cannot stay safe, or feel out of control, stay near a trusted person and contact emergency or crisis support now.", size=27, max_width=870)
    y = text(draw, (x, y + 4), "اگر خود کو نقصان پہنچانے کا خطرہ ہو یا آپ محفوظ نہ رہ سکیں تو فوری طور پر کسی قابل اعتماد فرد کے پاس رہیں اور ایمرجنسی مدد لیں۔", size=27, bold=True, max_width=870, rtl=True)
    y += 24
    for name, phone, desc in [
        ("Rescue 1122", "1122 / 112 from mobile phones", "Ambulance and emergency response in Pakistan."),
        ("Police emergency", "15", "Use when immediate personal safety is threatened."),
        ("Umang Pakistan", "(92) 0311 7786264 / 0311 77UMANG", "Mental health helpline and suicide prevention support."),
        ("Rozan counselling", "0092 3355000401 / 0402 / 0403", "Counselling support listed in WHO EMRO Pakistan crisis resources."),
    ]:
        text(draw, (x, y), f"{name}: {phone}", size=27, bold=True, max_width=870)
        y = text(draw, (x, y + 42), desc, size=24, fill=MUTED, max_width=870)
        y += 10
    img.save(OUT_DIR / "04-mental-wellness-crisis.png")


def screen_dashboard():
    img = new_canvas()
    draw = ImageDraw.Draw(img)
    header(draw, "Analysis Dashboard", "Daily, weekly, and monthly records with charts, trends, todos, and history.")
    x, y, _ = card(draw, 200, "Today Summary", 430)
    metric(draw, x, y, "Adherence", "76/100", PRIMARY)
    metric(draw, x + 310, y, "Health flags", "4", WARN)
    metric(draw, x + 620, y, "Meals", "3", TERTIARY)
    y += 160
    y = progress_line(draw, x, y, "Calorie target", "62%", 0.62, PRIMARY)
    y = progress_line(draw, x, y, "Burn target", "88%", 0.88, TERTIARY)
    progress_line(draw, x, y, "Protein progress", "55%", 0.55, SECONDARY)

    x, y, _ = card(draw, 660, "Charts & Trends", 650)
    y = bar_chart(draw, x, y, "Recent calorie intake", ["05-27", "05-28", "05-29", "05-30", "05-31", "06-02"], [330, 800, 460, 390, 460, 1240], PRIMARY)
    y = bar_chart(draw, x, y + 8, "Recent calories burned", ["05-27", "05-28", "05-29", "05-30", "05-31", "06-02"], [240, 320, 280, 350, 300, 350], TERTIARY)
    text(draw, (x, y + 8), "Calorie trend: Improving", size=29, bold=True)
    text(draw, (x, y + 56), "Recent average intake is close enough to target for a useful week.", size=24, fill=MUTED)

    x, y, _ = card(draw, 1340, "Todo & History", 390)
    y = bullets(draw, x, y, [
        "[x] Log at least two meals",
        "[ ] Add a short walk",
        "[ ] Add protein anchor",
        "[ ] Review health flags",
        "[x] Plan tomorrow's first meal",
    ], size=26)
    text(draw, (x, y + 18), "Newest history", size=30, bold=True)
    bullets(draw, x, y + 68, [
        "2026-06-02: 1240 in / 350 burned / 890 net",
        "2026-05-31: 460 in / 300 burned / 160 net",
    ], size=24)
    img.save(OUT_DIR / "05-analysis-dashboard.png")


def screen_food():
    img = new_canvas()
    draw = ImageDraw.Draw(img)
    header(draw, "Food Logging", "Desi catalog, manual food entry, meal calories, and records.")
    x, y, _ = card(draw, 200, "Desi Food Catalog", 420)
    text(draw, (x, y), "35+ items covering roti, rice, daal, dishes, desserts, drinks, and snacks.", size=26, fill=MUTED, max_width=870)
    y += 80
    y = chip_row(draw, x, y, ["Roti/rice", "Daal", "Protein", "Sabzi", "Dairy", "Desi dish", "Dessert", "Drink", "Snack"], selected=["Desi dish"])
    y = chip_row(draw, x, y + 16, ["Chicken biryani - 650 kcal", "Chicken karahi - 520 kcal", "Nihari - 560 kcal", "Haleem - 430 kcal"], selected=["Chicken biryani - 650 kcal"])

    x, y, _ = card(draw, 650, "Manual Food Entry", 430)
    for label, value in [("Category", "Home foods"), ("Food item", "Aloo gosht"), ("Serving", "1 bowl")]:
        text(draw, (x, y), label, size=23, fill=MUTED)
        round_rect(draw, (x, y + 34, x + 870, y + 88), 12, "#F8FAF6", outline="#DCE4D6")
        text(draw, (x + 20, y + 46), value, size=25, max_width=830)
        y += 104
    slider(draw, x, y, "Calories per serving", "420 kcal", 420 / 900, SECONDARY)

    x, y, _ = card(draw, 1110, "Meal Log & Records", 620)
    text(draw, (x, y), "Selected: Chicken biryani (1 plate, 650 kcal, Halal)", size=27, bold=True, max_width=870)
    y += 58
    y = slider(draw, x, y, "Servings", "1.0", 0.22, PRIMARY)
    y = slider(draw, x, y, "Calories burned today", "350 kcal", 0.29, TERTIARY)
    y = bullets(draw, x, y + 8, [
        "Breakfast: Chai with sugar x 1.0 = 110 kcal",
        "Lunch: Chicken biryani x 1.0 = 650 kcal",
        "Dinner: Daal x 1.0 + Roti x 2.0 = 460 kcal",
    ], size=24)
    y += 12
    for label, value in [
        ("Today", "1220 kcal in / 350 burned / 870 net / 3 meals"),
        ("This week", "4120 kcal in / 1840 burned / 2280 net / 12 meals"),
        ("This month", "5210 kcal in / 2200 burned / 3010 net / 15 meals"),
    ]:
        text(draw, (x, y), f"{label}: {value}", size=25, bold=True, max_width=870)
        y += 44
    img.save(OUT_DIR / "06-food-logging-records.png")


def contact_sheet():
    files = sorted(OUT_DIR.glob("0*.png"))
    thumb_w, thumb_h = 324, 576
    sheet = Image.new("RGB", (1120, 1260), BG)
    draw = ImageDraw.Draw(sheet)
    text(draw, (44, 34), "PakFit App Screens", size=48, bold=True)
    text(draw, (44, 94), "Generated visual previews from the implemented Android MVP.", size=25, fill=MUTED)
    positions = [(44, 160), (398, 160), (752, 160), (44, 780), (398, 780), (752, 780)]
    for path, (x, y) in zip(files, positions):
        img = Image.open(path).resize((thumb_w, thumb_h))
        round_rect(draw, (x - 8, y - 8, x + thumb_w + 8, y + thumb_h + 8), 22, "#EAF0E5")
        sheet.paste(img, (x, y))
        label = path.stem[3:].replace("-", " ").title()
        text(draw, (x, y + thumb_h + 16), label, size=22, bold=True, max_width=thumb_w)
    sheet.save(OUT_DIR / "00-pakfit-screen-contact-sheet.png")


if __name__ == "__main__":
    screen_home()
    screen_health()
    screen_clinical()
    screen_mental()
    screen_dashboard()
    screen_food()
    contact_sheet()
    print(f"Rendered screens to {OUT_DIR}")
