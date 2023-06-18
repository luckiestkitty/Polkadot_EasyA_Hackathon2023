# tutorial https://www.youtube.com/watch?v=Rw84iRwFbJQ
import slack_sdk as slack
import os
from flask import Flask, jsonify
from slackeventsapi import SlackEventAdapter
import openai
import threading

def process_event(event):
  messages = [{'role': 'system', 'content': 'You are a friendly chatbot.'}]

  channel = event.get("channel")
  user = event.get("user")
  text = event.get("text")
  ts = event.get("ts")

  # Only respond if the bot is mentioned
  if f'<@{bot}>' not in text:
    return

  messages.append({'role': 'user', 'content': f"{text}"})
  response = get_completion_from_messages(messages)
  client.chat_postMessage(channel=channel, text=response, thread_ts=ts)


def get_completion_from_messages(messages,
                                 model="gpt-3.5-turbo",
                                 temperature=0):
   
   openai.api_key = os.environ['OPENAI_API_KEY']
   completion = openai.ChatCompletion.create(
        model="gpt-3.5-turbo-0613",
        messages=messages,
    )

   return {"response": completion.choices[0].message["content"]}
 

  

messages = [{'role': 'system', 'content': 'You are friendly Polkadot blockchain chatbot.'}]

app = Flask(__name__)

eventAdaptor = SlackEventAdapter(os.environ["SLACK_SIGN_SECRECT"],
                                 "/slack/events", app)

client = slack.WebClient(token=os.environ["Bot_Slack_Token"])

bot = client.api_call("auth.test")["user_id"]

count = 0


@eventAdaptor.on("message")
def onMessage(message):
  global count  # Add this line
  print("count: ", count)
  count += 1
  event = message.get("event", {})
  channel = event.get("channel")
  user = event.get("user")
  text = event.get("text")
  ts = event.get("ts")

  print("bot", bot)
  print("text", text)
  # Ignore bot's own messages
  if 'subtype' in event and event['subtype'] == 'bot_message':
    return jsonify({'status': 'OK'})

  
  # Process the event in a separate thread
  threading.Thread(target=process_event, args=(event,)).start()

  return jsonify({'status': 'OK'})


app.run(host="0.0.0.0", port=5000, debug=True)
