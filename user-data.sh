#!/bin/bash
yum update -y
python3 -m pip install aiohttp
python3 -m pip install asyncio

cat <<EOT >> /root/main.py
import os

from aiohttp import web


async def handle(request):

    if os.getenv('DYN_STRING') is None:
        dyn_string = "The saved string is dynamic string"
        os.environ['DYN_STRING'] = dyn_string
    else:
        dyn_string = os.getenv('DYN_STRING')
    new_string = request.match_info.get('string', dyn_string)

    if dyn_string != new_string and new_string != "" and new_string != "favicon.ico":
        os.environ['DYN_STRING'] = new_string.capitalize()

    text = "<h1>\"" + os.getenv('DYN_STRING') + "\"</h1>"
    print('Request served!\n' + text)
    return web.Response(text=text, content_type='text/html')


app = web.Application()

app.add_routes([web.get('/', handle),
                web.get('/{string}', handle)])

if __name__ == '__main__':
    web.run_app(app, port=80)

EOT
python3 /root/main.py &>/dev/null &