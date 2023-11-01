import time
from datetime import datetime
import requests
import os
import sys
import asyncio
import aiohttp
from concurrent.futures import ThreadPoolExecutor

import yt_dlp

import whisper
from whisper.utils import get_writer


YT_API_KEY = 'AIzaSyAFOCW-YXn_yY7x9S1Dq_zLF7BD5ewcuew'

# https://stackoverflow.com/questions/64825310/downloading-data-directly-into-a-temporary-file-with-python-youtube-dl
ydl_opts = {
    'outtmpl': './%(uploader)s/%(title)s_%(release_date)s.%(ext)s',
    'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
    'merge_output_format': 'mp4',
    'writethumbnail' : True,
    'writedescription': True,
    'nocheckcertificate': True,
    # CHROMIUM_BASED_BROWSERS = {'brave', 'chrome', 'chromium', 'edge', 'opera', 'vivaldi'}
    # 'cookiesfrombrowser': ('edge',),
    'cookiefile': 'youtube.com_cookies.txt',
    'live_from_start': True,
    "nopart": True
}

ydl_opts_skip_dl = {
    'outtmpl': './%(uploader)s/%(title)s_%(release_date)s.%(ext)s',
    'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
    'merge_output_format': 'mp4',
    'writethumbnail': True,
    "nopart": True,
    # 'cookiefile': 'youtube.com_cookies.txt',
    # CHROMIUM_BASED_BROWSERS = {'brave', 'chrome', 'chromium', 'edge', 'opera', 'vivaldi'}
    'cookiesfrombrowser': ('edge',),
    'skip_download': True,
}

mp3_opts = {
    'format': 'bestaudio/best',
    'writethumbnail': True,
    'writedescription': True,
    'postprocessors': [{
        'key': 'FFmpegExtractAudio',
        'preferredcodec': 'mp3',
        'preferredquality': '320',
    }],
    'nocheckcertificate': True
}


async def create_session():
    return aiohttp.ClientSession()

# def dl_main(opts, url):

#     with yt_dlp.YoutubeDL(opts) as ydl:
#         info = ydl.extract_info(url)
#         print_info(info)

#         thumbnail = sorted(filter(lambda d: d.get('height') is not None, info['thumbnails']), key = lambda x: x['height'])[-1]
#         print(f'"thumbnail":{thumbnail["url"]}')
#         # img = requests.get(thumbnail['url'],verify=False)  # 下載圖片
#         img = requests.get(thumbnail['url'])  # 下載圖片
#         with open(f"./{info['uploader']}/{info['title']}_{info['release_date']}.jpg", "wb") as file:  # 開啟資料夾及命名圖片檔
#             file.write(img.content)

#     return info

async def dl_main(opts, url):
    session = await create_session()

    async with session:
        local_opts = opts.copy()  # 創建 opts 的副本
        local_opts['skip_download'] = True  # 僅修改副本
        
        with yt_dlp.YoutubeDL(opts) as ydl:
            info = ydl.extract_info(url)
            thumbnail = sorted(filter(lambda d: d.get('height') is not None, info['thumbnails']), key=lambda x: x['height'])[-1]
            print(f'"thumbnail":{thumbnail["url"]}')
            print(f"file path:{ydl.get_output_path()}")

        img_task = asyncio.create_task(download_img(session, thumbnail, info))
        video_task = asyncio.create_task(download_video(opts, url))
        
        await asyncio.gather(img_task, video_task)

    return info

# 單獨用於打印資訊的函數
def print_info(info):
    print(f"live_status:{info.get('live_status', 'N/A')}")
    print(f"channel:{info.get('channel', 'N/A')}")
    print(f"is_live:{info.get('is_live', 'N/A')}")
    print(f"upload_date:{info.get('upload_date', 'N/A')}")
    print(f"uploader:{info.get('uploader', 'N/A')}")
    print(f"title:{info.get('title', 'N/A')}")

async def download_img(session, thumbnail, info):
    async with session.get(thumbnail['url']) as resp:
        img_content = await resp.read()
        try:
            print(f"down load image : {info['uploader']} {info['title']}")
            with open(f"./{info['uploader']}/{info['title']}_{info['release_date']}.jpg", "wb") as file:
                file.write(img_content)
        except FileNotFoundError:
            print(f"try download image fail now try use fath :{info['title']}_{info['uploader']}_{info['release_date']}.jpg")
            with open(f"{info['title']}_{info['uploader']}_{info['release_date']}.jpg", "wb") as file:
                file.write(img_content)

async def download_video(opts, url):
    with yt_dlp.YoutubeDL(opts) as ydl:
        info = ydl.extract_info(url)
        file_path = ydl.get_output_path()
        print(f"download success path : {file_path}")
    
    return file_path

def count_down(num, t_name='分鐘', wait_sec=60):

    print(f'wait {str(num)} t_name')
    t_num = int(num)

    if 'hours' in t_name:
        t_num = t_num * 60

    print('Start count down :' + datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    for i in range(t_num):

        print(f'need {str(t_num - i)} 分鐘')
        time.sleep(wait_sec)

    now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f'End count down :{now}')


def main(argv):
    # if 'https://youtu.be/' in argv[1]:
    print(f'Get url :{argv}')
    # elif 'h' == argv[1] or 'help' == argv[1]:
    #     print('please enter url like https://youtu.be/your_video_path')
    #     print('for example python3 ')
    # else:
    #     print('need url like: https://youtu.be/your_video_path')
    #
    # if len(argv) >= 3:
    #     print('Get folder path :' + argv[2])
    #     ydl_opts['outtmpl'] = argv[2] + '/%(title)s.%(ext)s'
    # if len(argv) >= 4:
    #     print('Get download type :' + argv[3])
    #     if 'mp3' == argv[3]:
    #         print('Use mp3 mode')
    #         ydl_opts = mp3_opts
    #     else:
    #         print('Use default mp4 mode')

    # if 'https://youtu.be' in argv[1]:
    url = argv[1]
    wait_dl(url)
    # else:
    #     print('need url like: https://youtu.be/{your_video_path}')


def wait_dl(yt_url):

    if('youtu' not in yt_url):
        ydl_opts['live_from_start'] = False

    i = ''
    info = {}
    try:
        info = asyncio.run(dl_main(ydl_opts, yt_url))
        i = 'done'

    except yt_dlp.utils.DownloadError as e:

        i = str(e.exc_info[1])
        i_arr = i.split(' ')
        print(f'DownloadError =>{i_arr}')

        if 'event will begin' in i or '將於' in i:

            if 'few' in i or '幾分鐘' in i:
                count_down(1, wait_sec=10)
            else:
                t = i_arr[-2]
                t_str = i_arr[-1]
                count_down(t, t_str)

        elif 'Premieres' in i or '將在' in i:
            t = i_arr[2]
            t_str = i_arr[-1]
            count_down(t, t_str)

    except Exception as e:
        print(type(e))
        print(e)
        i = str(e)

    print('========= 148')
    print(i)

    if 'will begin' in i or '將於' in i:
        info = wait_dl(yt_url)
    else:
        print('line 154')
        print(i)

    return info

def get_now(format_str :str ="%Y-%m-%d %H:%M:%S"):
    return datetime.now().strftime(format_str)

async def transcribe_audio(file_path:str):

    print(f'start transcribe_audio : {get_now()}')

    loop = asyncio.get_event_loop()
    output_directory = os.path.dirname(file_path)
    model = whisper.load_model("large-v2", device="cuda")
    input_file = f"{file_path}".replace("mp4", "srt")

    with ThreadPoolExecutor() as pool:
        print(f'loading file : {get_now()}')

        # Load the audio file in a separate thread
        audio = await loop.run_in_executor(pool, lambda: whisper.load_audio(file_path))

        print(f'transcribe : {get_now()}')

        # Transcribe the audio in a separate thread
        transcription = await loop.run_in_executor(pool, lambda: model.transcribe(audio))

        print(f'write file : {get_now()}')

        # Save as an SRT file
        srt_writer = get_writer("srt", output_directory)
        await loop.run_in_executor(pool, lambda: srt_writer(transcription, input_file, {}))

        print(f'done : {get_now()}')


if __name__ == "__main__":
    main(sys.argv)
