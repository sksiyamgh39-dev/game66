import os
from flask import Flask
import threading
import telebot

# রেন্ডারকে পোর্ট দেওয়ার জন্য ফ্লাস্ক সার্ভার
app = Flask(__name__)

@app.route('/')
def home():
    return "Bot is alive and running!"

def run_flask():
    port = int(os.environ.get("PORT", 10000))
    app.run(host="0.0.0.0", port=port)

# আলাদা থ্রেডে ফ্লাস্ক চালু করা
flask_thread = threading.Thread(target=run_flask)
flask_thread.start()

# আপনার টেলিগ্রাম বটের টোকেন
TOKEN = "8887646945:AAHnUgGUifYodcfqmHuwXyWDIQKSEA-0hL4"
bot = telebot.TeleBot(TOKEN)

@bot.message_handler(commands=['start'])
def send_welcome(message):
    bot.reply_to(message, "স্বাগতম! বট সফলভাবে চালু হয়েছে।")

@bot.message_handler(func=lambda message: True)
def echo_all(message):
    bot.reply_to(message, f"আপনি লিখেছেন: {message.text}")

if __name__ == "__main__":
    bot.infinity_polling()
    
