import os
from flask import Flask
import threading
import telebot

# ফ্লাস্ক সার্ভার ইনিশিয়ালাইজ
app = Flask(__name__)

@app.route('/')
def home():
    return "Bot is alive and running!"

def run_flask():
    port = int(os.environ.get("PORT", 10000))
    app.run(host="0.0.0.0", port=port)

# টেলিগ্রাম বটের টোকেন
TOKEN = "8887646945:AAHnUgGUifYodcfqmHuwXyWDIQKSEA-0hL4"
bot = telebot.TeleBot(TOKEN)

@bot.message_handler(commands=['start'])
def send_welcome(message):
    bot.reply_to(message, "স্বাগতম! বট সফলভাবে চালু হয়েছে।")

@bot.message_handler(func=lambda message: True)
def echo_all(message):
    bot.reply_to(message, f"আপনি লিখেছেন: {message.text}")

if __name__ == "__main__":
    # প্রথমে ফ্লাস্ক সার্ভারটি ব্যাকগ্রাউন্ড থ্রেডে চালু করা হচ্ছে
    flask_thread = threading.Thread(target=run_flask)
    flask_thread.daemon = True
    flask_thread.start()
    
    # এরপর মূল থ্রেডে টেলিগ্রাম বট পোলিং শুরু করা হচ্ছে
    print("Bot is polling...")
    bot.infinity_polling()
    
