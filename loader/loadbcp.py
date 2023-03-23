import asyncio
import uvloop
import time
import asyncstdlib.itertools as itertools
import math
from app import app


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
