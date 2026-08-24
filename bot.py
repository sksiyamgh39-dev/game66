import os
from flask import Flask
import threading
from telegram import ReplyKeyboardMarkup, ReplyKeyboardRemove, Update
from telegram.ext import (
    ApplicationBuilder,
    CommandHandler,
    ContextTypes,
    MessageHandler,
    filters,
)

# রেন্ডারকে পোর্ট দেওয়ার জন্য ফ্লাস্ক সার্ভার
app = Flask(__name__)

@app.route('/')
def home():
    return "Bot is alive!"

def run_flask():
    port = int(os.environ.get("PORT", 10000))
    app.run(host="0.0.0.0", port=port)

# আলাদা থ্রেডে ফ্লাস্ক চালু করা
flask_thread = threading.Thread(target=run_flask)
flask_thread.start()

# আপনার টেলিগ্রাম বটের টোকেন
TOKEN = "8887646945:AAHnUgGUifYodcfqmHuwXyWDIQKSEA-0hL4"

# স্টার্ট কমান্ড হ্যান্ডলার
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    keyboard = [
        ["🛒 Buy Product"],
        ["👤 My Profile", "💳 Deposit"],
        ["🛡️ Get Code", "📞 Support"]
    ]
    reply_markup = ReplyKeyboardMarkup(keyboard, resize_keyboard=True)
    await update.message.reply_text("<b>Welcome to QuickPay!</b>", reply_markup=reply_markup, parse_mode="HTML")

# সাধারণ টেক্সট মেসেজ হ্যান্ডলার
async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    text = update.message.text
    if text == "🛒 Buy Product":
        await update.message.reply_text("প্রোডাক্ট কেনার প্রক্রিয়া চলছে...")
    elif text == "👤 My Profile":
        await update.message.reply_text("আপনার প্রফাইল তথ্য:")
    elif text == "💳 Deposit":
        await update.message.reply_text("ব্যালেন্স রিচার্জ করতে পেমেন্ট পদ্ধতি বেছে নিন।")
    elif text == "🛡️ Get Code":
        await update.message.reply_text("আপনার কোডটি এখানে দেওয়া হলো:")
    elif text == "📞 Support":
        await update.message.reply_text("সাপোর্ট টিমের সাথে যোগাযোগ করুন: @SupportAdmin")
    else:
        await update.message.reply_text("দয়া করে নিচের বাটনগুলো ব্যবহার করুন।")

# বট রান করার মূল অংশ
if __name__ == "__main__":
    application = ApplicationBuilder().token(TOKEN).build()

    application.add_handler(CommandHandler("start", start))
    application.add_handler(
        MessageHandler(filters.TEXT & (~filters.COMMAND), handle_message)
    )

    print("বট সফলভাবে চালু হয়েছে...")
    application.run_polling()
    
