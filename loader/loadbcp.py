import asyncio
from typing import AsyncIterator, List
import uvloop
import time
import asyncstdlib.itertools as itertools
import math
from app import app
from app import taget_chat

import pyrogram

def is_file(msg: pyrogram.types.Message):
    return msg.document

def make_progress(msg: pyrogram.types.Message):
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

    chat = await app.get_chat(taget_chat)

    print("getting messages")
    history = app.get_chat_history(chat_id=chat.id)

    to_load: AsyncIterator[pyrogram.types.Message] = itertools.takewhile(
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
