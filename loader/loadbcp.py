import asyncio
import uvloop
from pyrogram import Client
import time
import asyncstdlib.itertools as itertools
import math

api_id = 741567 #!! 
api_hash = "29bca2c6df033b2a62fbc6e6c57892c9" #!

uvloop.install()

app = Client("my_account", api_id, api_hash)


def is_file(msg):
    return msg.document


def make_progress(msg):
    name = msg.document.file_name
    return lambda current, total: print(
        f"""{name}: loaded {current} of {total} ({
            math.floor(current / total * 100_00) / 100
        } %) """
    )

async def main():
    print("starting")
    await app.start()

    print("getting chat")
    #app.send_message("me", "hi")
    chat = await app.get_chat("@sexclubbackups")

    print("getting messages")
    history = app.get_chat_history(chat_id=chat.id)

    to_load = itertools.takewhile(
        is_file, itertools.dropwhile(lambda x: not is_file(x), history)
    )

    print("loading")
    loaded = [
        msg.download(
            progress=make_progress(msg),
            file_name="loaded/"
        ) async for msg in to_load
    ]

    await asyncio.gather(*loaded)

app.run(main())
