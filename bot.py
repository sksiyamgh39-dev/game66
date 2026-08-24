import os
from flask import Flask, request
import telebot

# আপনার টেলিগ্রাম বটের টোকেন
TOKEN = "8887646945:AAHnUgGUifYodcfqmHuwXyWDIQKSEA-0hL4"
bot = telebot.TeleBot(TOKEN)

# ফ্লাস্ক সার্ভার ইনিশিয়ালাইজ
app = Flask(__name__)

@app.route('/')
def home():
    return "Bot is alive and running!"

# টেলিগ্রাম থেকে আপডেট রিসিভ করার জন্য ওয়েব হুক রুট
@app.route(f'/{TOKEN}', methods=['POST'])
def webhook():
    if request.headers.get('content-type') == 'application/json':
        json_string = request.get_data().decode('utf-8')
        update = telebot.types.Update.de_json(json_string)
        bot.process_new_updates([update])
        return "!", 200
    else:
        return "Invalid content type", 403

@bot.message_handler(commands=['start'])
def send_welcome(message):
    bot.reply_to(message, "স্বাগতম! ওয়েব হুক মোডে বট সফলভাবে চালু হয়েছে।")

@bot.message_handler(func=lambda message: True)
def echo_all(message):
    bot.reply_to(message, f"আপনি লিখেছেন: {message.text}")

if __name__ == "__main__":
    # বটের জন্য রেন্ডারের লাইভ ওয়েব ইউআরএল সেট করতে হবে
    # রেন্ডার ড্যাশবোর্ড থেকে আপনার প্রজেক্টের URL টি কপি করুন (যেমন: https://your-app-name.onrender.com)
    RENDER_URL = os.environ.get("RENDER_EXTERNAL_URL") 
    
    if RENDER_URL:
        bot.remove_webhook()
        bot.set_webhook(url=f"{RENDER_URL}/{TOKEN}")
        print(f"Webhook set to: {RENDER_URL}/{TOKEN}")

    # ফ্লাস্ক সার্ভার চালু করা
    port = int(os.environ.get("PORT", 10000))
    app.run(host="0.0.0.0", port=port)
    
    
