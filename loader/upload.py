import os
from app import app
from app import taget_chat
import math


def make_progress(name):
    return lambda current, total: print(
        f"""{name}: uploaded {current} of {total} ({
            math.floor(current / total * 100_00) / 100
        } %) """
    )


async def main():
    print("starting")
    await app.start()

    print("getting chat")
    chat = await app.get_chat(taget_chat)


    inputs = os.listdir("./input")
    print(f"got input files: {inputs}")

    await app.send_message(chat.id, "==========  " * 4)

    for file in inputs:
        await app.send_document(chat.id, f'./input/{file}', progress=make_progress(file))



app.run(main())
