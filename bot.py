from telegram import ReplyKeyboardMarkup, Update
from telegram.ext import (
    ApplicationBuilder,
    CommandHandler,
    ContextTypes,
    MessageHandler,
    filters,
)

# আপনার টোকেনটি এখানে বসানো আছে
TOKEN = "8887646945:AAHnUgGUifYodcfqmHuwXyWDIQKSEA-0hL4"


async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    keyboard = [
        ["🛍️ Buy Product"],
        ["👤 My Profile", "💳 Deposit"],
        ["🛡️ Get Code", "📞 Support"],
    ]
    reply_markup = ReplyKeyboardMarkup(keyboard, resize_keyboard=True)

    welcome_text = "<b>Welcome to Quick Store </b> 👋\n\nআপনাকে স্বাগতম!"
    await update.message.reply_text(
        welcome_text, parse_mode="HTML", reply_markup=reply_markup
    )


async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    text = update.message.text

    if text == "🛍️ Buy Product":
        await update.message.reply_text(
            "পণ্য কেনার জন্য আমাদের তালিকা নিচে দেওয়া হলো:"
        )
    elif text == "👤 My Profile":
        await update.message.reply_text(
            "আপনার প্রফাইল ইনফরমেশন:\nID: 123456\nBalance: 0.00 BDT"
        )
    elif text == "💳 Deposit":
        await update.message.reply_text("ব্যালেন্স রিচার্জ করতে পেমেন্ট করুন...")
    elif text == "🛡️ Get Code":
        await update.message.reply_text("আপনার কোডটি হলো: XXX-XXX")
    elif text == "📞 Support":
        await update.message.reply_text(
            "সাপোর্ট টিমের সাথে যোগাযোগ করুন: @SupportAdmin"
        )
    else:
        await update.message.reply_text(
            "দয়া করে নিচের বাটনগুলো ব্যবহার করুন অথবা /start লিখুন।"
        )


if __name__ == "__main__":
    app = ApplicationBuilder().token(TOKEN).build()

    app.add_handler(CommandHandler("start", start))
    app.add_handler(
        MessageHandler(filters.TEXT & (~filters.COMMAND), handle_message)
    )

    print("স্টোর বট সফলভাবে চালু হয়েছে...")
    app.run_polling()
  
